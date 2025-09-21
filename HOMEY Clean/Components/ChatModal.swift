//
//  ChatModal.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//

import SwiftUI

struct ChatModal: View {
    let target: ChatTarget
    let currentContext: ChatContext?
    @Environment(\.dismiss) private var dismiss

    struct Msg: Identifiable {
        let id = UUID()
        let text: String
        let isUser: Bool
        let quickActions: [QuickAction]?
        let isProactive: Bool
        
        init(text: String, isUser: Bool, quickActions: [QuickAction]? = nil, isProactive: Bool = false) {
            self.text = text
            self.isUser = isUser
            self.quickActions = quickActions
            self.isProactive = isProactive
        }
    }
    
    struct QuickAction: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let action: () -> Void
    }

    @State private var input = ""
    @State private var messages: [Msg] = []
    @State private var isTyping = false
    @State private var proactiveTimer: Timer?

    init(target: ChatTarget, currentContext: ChatContext? = nil) {
        self.target = target
        self.currentContext = currentContext
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List(messages) { m in
                    VStack(alignment: m.isUser ? .trailing : .leading, spacing: 8) {
                        HStack {
                            if m.isUser { Spacer() }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(m.text)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(m.isUser ? Color.blue.opacity(0.12) : (m.isProactive ? Color.orange.opacity(0.12) : Color.gray.opacity(0.12)))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                
                                if let quickActions = m.quickActions {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(quickActions.count, 2)), spacing: 8) {
                                        ForEach(quickActions) { action in
                                            Button(action: action.action) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: action.icon)
                                                        .font(.caption)
                                                    Text(action.title)
                                                        .font(.caption.weight(.medium))
                                                }
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.1))
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.leading, 12)
                                }
                            }
                            
                            if !m.isUser { Spacer() }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                
                if isTyping {
                    HStack {
                        Text("\(target.typingIndicator) is typing...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }

                HStack(spacing: 8) {
                    TextField("Type a message…", text: $input, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1 ... 4)

                    Button {
                        send()
                    } label: {
                        Image(systemName: "paperplane.fill").font(.title3)
                    }
                    .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(12)
                .background(.ultraThinMaterial)
            }
            .navigationTitle(target.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                setupInitialMessage()
                startProactiveTimer()
            }
            .onDisappear {
                proactiveTimer?.invalidate()
            }
        }
    }

    private func send() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(.init(text: trimmed, isUser: true))
        input = ""
        
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isTyping = false
            generatePersonaResponse(to: trimmed)
        }
    }
    
    private func setupInitialMessage() {
        let greeting = generateContextualGreeting()
        messages.append(greeting)
    }
    
    private func generateContextualGreeting() -> Msg {
        switch target {
        case .agent:
            let contextText = currentContext?.description ?? "general assistance"
            return Msg(text: "Hi! I'm here to help with \(contextText). What can I do for you?", isUser: false)
        case let .homey(kind):
            let personalityGreeting = getPersonalityGreeting(for: kind)
            let contextualPart = currentContext != nil ? " I see you're in \(currentContext!.description)." : ""
            return Msg(text: personalityGreeting + contextualPart, isUser: false, quickActions: getContextualQuickActions(for: kind))
        }
    }
    
    private func getPersonalityGreeting(for kind: HomeyKind) -> String {
        switch kind {
        case .charlie:
            return "Hey there! Charlie here, your deal sherpa. Ready to navigate this journey together?"
        case .paige:
            return "Hi! Paige at your service. Let's get your paperwork sorted and deadlines conquered."
        case .drew:
            return "Hello! Drew here to keep everyone connected and moving forward."
        case .scout:
            return "Hey! Scout reporting for duty. Ready to find exactly what you're looking for?"
        case .isla:
            return "Hi there! Isla here with all the neighborhood intel you need."
        case .viza:
            return "Hello! Viza ready to help you visualize and create your perfect space vision."
        }
    }
    
    private func getContextualQuickActions(for kind: HomeyKind) -> [QuickAction] {
        var actions: [QuickAction] = []
        
        switch kind {
        case .charlie:
            actions.append(QuickAction(title: "Book Tour", icon: "calendar") { /* Handle tour booking */ })
            actions.append(QuickAction(title: "Check Status", icon: "checkmark.circle") { /* Handle status check */ })
        case .paige:
            actions.append(QuickAction(title: "Upload Doc", icon: "doc.badge.plus") { /* Handle document upload */ })
            actions.append(QuickAction(title: "Review Checklist", icon: "list.bullet") { /* Handle checklist */ })
        case .drew:
            actions.append(QuickAction(title: "Schedule Meeting", icon: "person.2") { /* Handle meeting */ })
            actions.append(QuickAction(title: "Team Update", icon: "bubble.left.and.bubble.right") { /* Handle update */ })
        case .scout:
            actions.append(QuickAction(title: "New Search", icon: "magnifyingglass") { /* Handle search */ })
            actions.append(QuickAction(title: "Save Listing", icon: "heart") { /* Handle save */ })
        case .isla:
            actions.append(QuickAction(title: "Neighborhood Info", icon: "map") { /* Handle info */ })
            actions.append(QuickAction(title: "Market Data", icon: "chart.bar") { /* Handle data */ })
        case .viza:
            actions.append(QuickAction(title: "AR Preview", icon: "camera.viewfinder") { /* Handle AR */ })
            actions.append(QuickAction(title: "Vision Guide", icon: "paintbrush") { /* Handle vision */ })
        }
        
        return actions
    }
    
    private func generatePersonaResponse(to userMessage: String) {
        switch target {
        case .agent:
            let response = "I understand you're asking about '\(userMessage)'. Let me help you with that."
            messages.append(Msg(text: response, isUser: false))
        case let .homey(kind):
            let personalityResponse = getPersonalityResponse(for: kind, to: userMessage)
            messages.append(personalityResponse)
        }
    }
    
    private func getPersonalityResponse(for kind: HomeyKind, to message: String) -> Msg {
        let lowercaseMessage = message.lowercased()
        
        switch kind {
        case .charlie:
             if lowercaseMessage.contains("tour") || lowercaseMessage.contains("visit") {
                 let tourAction = QuickAction(title: "Book Now", icon: "calendar") { /* Handle booking */ }
                 return Msg(
                     text: "Perfect! Let's get that tour scheduled. I'll coordinate with everyone and make sure you're fully prepped.",
                     isUser: false,
                     quickActions: [tourAction]
                 )
             }
             return Msg(
                 text: "Got it! As your concierge, I'll make sure this gets handled smoothly. No chaos on my watch.",
                 isUser: false
             )
             
         case .paige:
             if lowercaseMessage.contains("document") || lowercaseMessage.contains("paperwork") {
                 let uploadAction = QuickAction(title: "Upload", icon: "doc.badge.plus") { /* Handle upload */ }
                 return Msg(
                     text: "Documents are my specialty! Let's get everything organized and deadline-ready.",
                     isUser: false,
                     quickActions: [uploadAction]
                 )
             }
             return Msg(
                 text: "I'm on it! Clean, organized, and deadline-focused - that's how we roll.",
                 isUser: false
             )
             
         case .drew:
             return Msg(
                 text: "Connecting the dots and keeping everyone aligned. That's what I do best!",
                 isUser: false
             )
             
         case .scout:
             if lowercaseMessage.contains("find") || lowercaseMessage.contains("search") {
                 let searchAction = QuickAction(title: "Start Search", icon: "magnifyingglass") { /* Handle search */ }
                 return Msg(
                     text: "Finding mode activated! I'll hunt down exactly what you're looking for.",
                     isUser: false,
                     quickActions: [searchAction]
                 )
             }
             return Msg(
                 text: "Scout here! Ready to track down whatever you need.",
                 isUser: false
             )
             
         case .isla:
             if lowercaseMessage.contains("neighborhood") || lowercaseMessage.contains("area") {
                 let reportAction = QuickAction(title: "Area Report", icon: "map") { /* Handle report */ }
                 return Msg(
                     text: "Neighborhood analysis is my thing! Let me break down the real intel for you.",
                     isUser: false,
                     quickActions: [reportAction]
                 )
             }
             return Msg(
                 text: "Data-driven insights coming your way! I'll analyze what matters most.",
                 isUser: false
             )
             
         case .viza:
            if lowercaseMessage.contains("vision") || lowercaseMessage.contains("design") {
                let visionAction = QuickAction(title: "Vision Guide", icon: "paintbrush") { /* Handle vision */ }
                return Msg(
                    text: "Vision consultation activated! Let's create something beautiful together.",
                    isUser: false,
                    quickActions: [visionAction]
                )
            }
             return Msg(
                 text: "Visual magic in progress! Let's make this space absolutely stunning.",
                 isUser: false
             )
        }
    }
    
    private func startProactiveTimer() {
        proactiveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            if messages.isEmpty || messages.last?.isUser == true {
                generateProactiveMessage()
            }
        }
    }
    
    private func generateProactiveMessage() {
        guard case let .homey(kind) = target else { return }
        
        let proactiveMessages = getProactiveMessages(for: kind)
        if let randomMessage = proactiveMessages.randomElement() {
            messages.append(Msg(text: randomMessage.text, isUser: false, quickActions: randomMessage.actions, isProactive: true))
        }
    }
    
    private func getProactiveMessages(for kind: HomeyKind) -> [(text: String, actions: [QuickAction])] {
        switch kind {
        case .charlie:
            return [
                ("Want me to nudge your lender about that pre-approval?", [QuickAction(title: "Yes, Nudge", icon: "phone") { /* Handle nudge */ }]),
                ("Ready to schedule your next property tour?", [QuickAction(title: "Book Tour", icon: "calendar") { /* Handle tour */ }])
            ]
        case .paige:
            return [
                ("I noticed some documents might need updates. Want me to check?", [QuickAction(title: "Check Docs", icon: "doc.text.magnifyingglass") { /* Handle check */ }]),
                ("Deadline coming up! Should we review your checklist?", [QuickAction(title: "Review", icon: "list.bullet") { /* Handle review */ }])
            ]
        case .drew:
            return [
                ("Time for a team sync? I can coordinate everyone's schedules.", [QuickAction(title: "Schedule", icon: "person.2") { /* Handle schedule */ }])
            ]
        case .scout:
            return [
                ("New listings just dropped in your area. Want to see them?", [QuickAction(title: "Show Me", icon: "house") { /* Handle listings */ }])
            ]
        case .isla:
            return [
                ("Market trends are shifting. Want the latest neighborhood analysis?", [QuickAction(title: "Get Report", icon: "chart.line.uptrend.xyaxis") { /* Handle report */ }])
            ]
        case .viza:
            return [
                ("Ready to visualize your space with AR? I've got new tools to show you.", [QuickAction(title: "Try AR", icon: "camera.viewfinder") { /* Handle AR */ }])
            ]
        }
    }
}

// MARK: - Chat Context

enum ChatContext {
    case documents
    case search
    case tours
    case neighborhood
    case team
    case settings
    case dashboard
    case networking
    case authentication
    
    var description: String {
        switch self {
        case .documents: return "Documents"
        case .search: return "Property Search"
        case .tours: return "Tours & Visits"
        case .neighborhood: return "Neighborhood Analysis"
        case .team: return "Team Coordination"
        case .settings: return "Settings"
        case .dashboard: return "Dashboard"
        case .networking: return "Networking"
        case .authentication: return "Authentication"
        }
    }
}

// MARK: - ChatTarget Extension

extension ChatTarget {
    var typingIndicator: String {
        switch self {
        case .agent: return "Your agent"
        case let .homey(kind): return kind.displayName
        }
    }
}
