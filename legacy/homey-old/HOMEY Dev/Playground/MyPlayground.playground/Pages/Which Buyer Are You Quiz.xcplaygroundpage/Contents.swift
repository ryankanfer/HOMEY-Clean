import SwiftUI
import PlaygroundSupport

// MARK: - Brand

struct Brand {
    // HOMEY vibes: cream, beige, soft neutrals, slate gray accents
    static let cream = Color(hex: "#F8F5F1")
    static let sand  = Color(hex: "#EDE4DA")
    static let clay  = Color(hex: "#D8CBBE")
    static let slate = Color(hex: "#2F4F4F") // primary text
    static let charcoal = Color(hex: "#222222")
    static let accent = Color(hex: "#4D7C7C") // calm mint-slate for CTAs
    static let accentAlt = Color(hex: "#6B9B9B")
}

extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r,g,b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r,g,b) = (255,255,255)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: 1.0)
    }
}

// MARK: - Models

struct QuizQuestion: Identifiable {
    let id = UUID()
    let prompt: String
    let options: [QuizOption]
}

struct QuizOption: Identifiable {
    let id = UUID()
    let text: String
    // Simple persona scoring. Tune these weights to taste.
    let weights: PersonaWeights
}

struct PersonaWeights {
    var isla: Int = 0      // The Strategic Analyst
    var scout: Int = 0     // The Intuitive Explorer
    var charlie: Int = 0   // The Location-First Strategist
    var paige: Int = 0     // The Efficiency Seeker
}

enum Persona: String {
    case isla, scout, charlie, paige
    var displayName: String {
        switch self {
        case .isla: return "The Strategic Analyst"
        case .scout: return "The Intuitive Explorer"
        case .charlie: return "The Location‑First Strategist"
        case .paige: return "The Efficiency Seeker"
        }
    }
    var homieName: String {
        switch self {
        case .isla: return "Isla"
        case .scout: return "Scout"
        case .charlie: return "Charlie"
        case .paige: return "Paige"
        }
    }
    var blurb: String {
        switch self {
        case .isla:
            return "You approach buying like a research project. Data first, then decisive action. Isla feeds you comps and context so your move is both smart and confident."
        case .scout:
            return "You trust your gut and want curated options. Scout surfaces hidden gems and helps you recognize 'the one' without overwhelm."
        case .charlie:
            return "You play the long game around lifestyle + location. Charlie decodes neighborhoods so your commute and corner bodega both slap."
        case .paige:
            return "You want clarity and speed. Paige streamlines the chaos — paperwork, scheduling, and next steps — so you can get on with your life."
        }
    }
    var emoji: String {
        switch self {
        case .isla: return "📊"
        case .scout: return "🧭"
        case .charlie: return "🗺️"
        case .paige: return "📑"
        }
    }
}

// MARK: - Sample Quiz Content (8 Qs)

let quiz: [QuizQuestion] = [
    QuizQuestion(
        prompt: "You see 'Charming Pre‑War Studio, $3,200/mo.' Your first thought?",
        options: [
            .init(text: "Character… or ancient plumbing?", weights: .init(isla: 1, paige: 1)),
            .init(text: "Show me building financials + comps.", weights: .init(isla: 2)),
            .init(text: "Is it in my target neighborhood?", weights: .init(charlie: 2)),
            .init(text: "Can I picture my life here?", weights: .init(scout: 2))
        ]
    ),
    QuizQuestion(
        prompt: "Co‑op board interview next week. How are we feeling?",
        options: [
            .init(text: "Stalking LinkedIns like it’s my job.", weights: .init(paige: 1, isla: 1)),
            .init(text: "Confident — my financials sing.", weights: .init(isla: 1)),
            .init(text: "Maybe I’m a condo era.", weights: .init(charlie: 1)),
            .init(text: "Practicing my ‘no parties’ face.", weights: .init(scout: 1))
        ]
    ),
    QuizQuestion(
        prompt: "A place 15% over budget but perfect appears. You…",
        options: [
            .init(text: "Run every scenario first.", weights: .init(isla: 2)),
            .init(text: "Trust the feeling.", weights: .init(scout: 2)),
            .init(text: "Counter at max and see.", weights: .init(charlie: 1, paige: 1)),
            .init(text: "Walk — boundaries exist.", weights: .init(paige: 2))
        ]
    ),
    QuizQuestion(
        prompt: "Biggest NYC real estate fear?",
        options: [
            .init(text: "Shaky building financials.", weights: .init(isla: 2)),
            .init(text: "Overpaying from ignorance.", weights: .init(isla: 1, scout: 1)),
            .init(text: "Outgrowing in two years.", weights: .init(charlie: 2)),
            .init(text: "Process eating my life.", weights: .init(paige: 2))
        ]
    ),
    QuizQuestion(
        prompt: "Saturday tours — ideal plan?",
        options: [
            .init(text: "3 researched options, deep dives.", weights: .init(isla: 2)),
            .init(text: "6–8 to feel the market.", weights: .init(scout: 2)),
            .init(text: "2 contenders + 1 reach.", weights: .init(charlie: 2)),
            .init(text: "One perfect match, quality > quantity.", weights: .init(paige: 2))
        ]
    ),
    QuizQuestion(
        prompt: "For your ideal home, what matters most?",
        options: [
            .init(text: "A place that feels like me.", weights: .init(scout: 2)),
            .init(text: "Smart investment + fundamentals.", weights: .init(isla: 2)),
            .init(text: "Neighborhood vibe + commute.", weights: .init(charlie: 2)),
            .init(text: "Affordability without pain.", weights: .init(paige: 2))
        ]
    ),
    QuizQuestion(
        prompt: "Friend asks for advice. You say…",
        options: [
            .init(text: "Here’s my 47‑point spreadsheet.", weights: .init(isla: 2)),
            .init(text: "Trust your gut + get an inspector.", weights: .init(scout: 2)),
            .init(text: "Location is king; rest is fixable.", weights: .init(charlie: 2)),
            .init(text: "Find a guide, follow the plan.", weights: .init(paige: 2))
        ]
    ),
    QuizQuestion(
        prompt: "Six months after closing, you want to feel…",
        options: [
            .init(text: "I made the smartest call.", weights: .init(isla: 2)),
            .init(text: "Completely at home.", weights: .init(scout: 2)),
            .init(text: "Proud of the strategic move.", weights: .init(charlie: 2)),
            .init(text: "Relieved and thriving.", weights: .init(paige: 2))
        ]
    )
]

// MARK: - ViewModels

final class QuizVM: ObservableObject {
    @Published var index: Int = 0
    @Published var answers: [UUID: QuizOption] = [:]
    @Published var done: Bool = false

    private(set) var totals = PersonaWeights()
    var current: QuizQuestion { quiz[index] }
    var progress: Double { Double(index) / Double(quiz.count) }

    func select(_ option: QuizOption) {
        answers[current.id] = option
        accumulate(option.weights)
        haptic(.light)
        advance()
    }

    private func accumulate(_ w: PersonaWeights) {
        totals.isla += w.isla
        totals.scout += w.scout
        totals.charlie += w.charlie
        totals.paige += w.paige
    }

    private func advance() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if index < quiz.count - 1 {
                index += 1
            } else {
                done = true
            }
        }
    }

    func topPersona() -> Persona {
        let scores: [(Persona, Int)] = [
            (.isla, totals.isla),
            (.scout, totals.scout),
            (.charlie, totals.charlie),
            (.paige, totals.paige)
        ]
        return scores.max(by: { $0.1 < $1.1 })?.0 ?? .charlie
    }
}

func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    UIImpactFeedbackGenerator(style: style).impactOccurred()
}

// MARK: - Components

struct RoundedCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(20)
            .background(Brand.sand.opacity(0.65))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Brand.clay.opacity(0.6), lineWidth: 1)
            )
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 12)
    }
}

struct HomeyButton: View {
    var title: String
    var action: () -> Void
    @State private var pressed = false
    var body: some View {
        Text(title)
            .font(.system(.headline, design: .rounded))
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(pressed ? Brand.accentAlt : Brand.accent)
            .cornerRadius(16)
            .scaleEffect(pressed ? 0.98 : 1.0) // cushion puff
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: pressed)
            .onLongPressGesture(minimumDuration: 0.25, pressing: { isPressing in
                pressed = isPressing
            }, perform: {
                haptic(.medium)
                action()
            })
            .onTapGesture {
                pressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    pressed = false
                    action()
                }
            }
    }
}

// MARK: - Screens

struct IntroView: View {
    @Binding var started: Bool
    var body: some View {
        VStack(spacing: 24) {
            Text("Which NYC Buyer Type Are You?")
                .font(.system(size: 34, weight: .semibold, design: .serif))
                .foregroundColor(Brand.slate)
                .multilineTextAlignment(.center)
                .padding(.top, 10)

            Text("Get matched with your perfect HOMEY guide in 2 minutes.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Brand.charcoal.opacity(0.75))
                .multilineTextAlignment(.center)

            RoundedCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Buying in NYC isn’t normal.")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Brand.slate)
                    Text("Between co‑op boards, bidding wars, and the ‘cozy’ 300‑sq‑ft special, strategy matters. Take the quiz to discover your buyer personality and meet the Homie who’ll have your back.")
                        .foregroundColor(Brand.charcoal.opacity(0.8))
                        .font(.system(.body, design: .rounded))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HomeyButton(title: "Start Quiz") {
                withAnimation(.easeInOut) { started = true }
            }
            .padding(.top, 8)

            Spacer(minLength: 0)
        }
        .padding(24)
        .background(Brand.cream.ignoresSafeArea())
    }
}

struct QuizView: View {
    @StateObject private var vm = QuizVM()
    @State private var showResult = false

    var body: some View {
        VStack(spacing: 20) {
            // Progress subway-style dot line (simplified)
            ProgressRail(progress: vm.progress)
                .padding(.top, 8)

            Text("Question \(vm.index + 1) of \(quiz.count)")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Brand.charcoal.opacity(0.7))

            Text(vm.current.prompt)
                .font(.system(size: 26, weight: .semibold, design: .serif))
                .foregroundColor(Brand.slate)
                .multilineTextAlignment(.center)
                .padding(.top, 4)

            VStack(spacing: 12) {
                ForEach(vm.current.options) { option in
                    OptionRow(text: option.text) {
                        vm.select(option)
                        if vm.done {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                withAnimation(.spring()) { showResult = true }
                            }
                        }
                    }
                }
            }
            .padding(.top, 6)

            Spacer()
        }
        .padding(24)
        .background(Brand.cream.ignoresSafeArea())
        .fullScreenCover(isPresented: $showResult) {
            ResultView(persona: vm.topPersona()) {
                // restart
                withAnimation {
                    showResult = false
                }
            }
        }
    }
}

struct OptionRow: View {
    var text: String
    var onSelect: () -> Void
    @State private var pressed = false

    var body: some View {
        Text(text)
            .font(.system(.body, design: .rounded))
            .foregroundColor(Brand.charcoal)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Brand.sand.opacity(pressed ? 0.95 : 0.7))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Brand.clay.opacity(0.7), lineWidth: 1)
            )
            .cornerRadius(14)
            .shadow(color: .black.opacity(pressed ? 0.03 : 0.06), radius: 12, x: 0, y: 6)
            .scaleEffect(pressed ? 0.985 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: pressed)
            .onTapGesture {
                pressed = true
                haptic(.light)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                    pressed = false
                    onSelect()
                }
            }
    }
}

struct ProgressRail: View {
    var progress: Double // 0...1
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Brand.clay.opacity(0.5))
                    .frame(height: 6)
                Capsule()
                    .fill(Brand.accent)
                    .frame(width: CGFloat(progress) * geo.size.width, height: 6)
                    .animation(.easeInOut(duration: 0.35), value: progress)
            }
        }
        .frame(height: 6)
    }
}

struct ResultView: View {
    let persona: Persona
    var onClose: () -> Void
    @State private var showShare = false

    var body: some View {
        VStack(spacing: 18) {
            Text("Your Buyer Type")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Brand.charcoal.opacity(0.7))
                .padding(.top, 6)

            Text("\(persona.emoji) \(persona.displayName)")
                .font(.system(size: 32, weight: .semibold, design: .serif))
                .foregroundColor(Brand.slate)
                .multilineTextAlignment(.center)

            RoundedCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Meet \(persona.homieName)")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Brand.slate)
                    Text(persona.blurb)
                        .foregroundColor(Brand.charcoal.opacity(0.9))
                        .font(.system(.body, design: .rounded))
                    Divider().opacity(0.3)
                    Text("Next up")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Brand.charcoal.opacity(0.7))
                    Label("Get your personalized NYC Buyer Guide", systemImage: "doc.richtext")
                    Label("Join the HOMEY waitlist for early access", systemImage: "checkmark.seal")
                    Label("Share your result with friends", systemImage: "square.and.arrow.up")
                }
                .labelStyle(.titleAndIcon)
            }

            HomeyButton(title: "Join the Waitlist") {
                // stub: integrate with your waitlist endpoint
                haptic(.medium)
            }

            Button {
                showShare.toggle()
            } label: {
                Text("Share Result")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Brand.accent)
                    .padding(.top, 2)
            }

            Button {
                onClose()
            } label: {
                Text("Retake Quiz")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(Brand.charcoal.opacity(0.7))
            }
            .padding(.top, 4)

            Spacer(minLength: 0)
        }
        .padding(24)
        .background(Brand.cream.ignoresSafeArea())
        .sheet(isPresented: $showShare) {
            ShareCard(persona: persona)
                .presentationDetents([.height(420)])
        }
    }
}

struct ShareCard: View {
    let persona: Persona
    var body: some View {
        VStack(spacing: 16) {
            Text("I’m \(persona.displayName) \(persona.emoji)")
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundColor(Brand.slate)
                .multilineTextAlignment(.center)
                .padding(.top, 16)

            RoundedCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Matched with \(persona.homieName) on HOMEY")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Brand.charcoal)
                    Text(persona.blurb)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(Brand.charcoal.opacity(0.8))
                }
            }

            Text("homey.nyc/quiz")
                .font(.system(.footnote, design: .monospaced))
                .foregroundColor(Brand.charcoal.opacity(0.7))

            Spacer()
        }
        .padding(20)
        .background(Brand.cream.ignoresSafeArea())
    }
}

// MARK: - Root Container

struct RootView: View {
    @State private var started = false

    var body: some View {
        ZStack {
            if started {
                QuizView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)))
            } else {
                IntroView(started: $started)
                    .transition(.opacity)
            }

            // Subtle brand texture overlay (noise-ish)
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.0), Brand.sand.opacity(0.15)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Playground LiveView

let live = RootView()
PlaygroundPage.current.setLiveView(
    AnyView(live.frame(width: 430, height: 860)) // iPhone-ish canvas
)
