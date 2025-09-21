import SwiftUI

// MARK: - Episode Detail Sheet

struct EpisodeDetailSheet: View {
    let episode: JourneyEpisode
    @Binding var isPresented: Bool
    @State private var showingActionSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section
                    VStack(spacing: 16) {
                        // Episode Poster
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [episode.status.color.opacity(0.3), episode.status.color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 280)
                            .overlay {
                                VStack {
                                    Image(systemName: episode.actionType.systemIcon)
                                        .font(.system(size: 40, weight: .light))
                                        .foregroundColor(episode.status.color)

                                    Spacer()

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(episode.title)
                                            .font(.custom("JosefinSans-SemiBold", size: 18))

                                        Text(episode.subtitle)
                                            .font(.custom("PlayfairDisplay-Regular", size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)
                                }
                                .padding(.top, 20)
                            }
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

                        // Status Badge
                        HStack {
                            Circle()
                                .fill(episode.status.color)
                                .frame(width: 8, height: 8)

                            Text(episode.status.displayName)
                                .font(.custom("JosefinSans-Medium", size: 12))
                                .foregroundColor(episode.status.color)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(episode.status.color.opacity(0.1))
                        )
                    }

                    // Episode Info
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About This Episode")
                                .font(.custom("JosefinSans-SemiBold", size: 20))

                            Text(episode.description)
                                .font(.custom("PlayfairDisplay-Regular", size: 16))
                                .foregroundColor(.secondary)
                                .lineLimit(nil)
                        }

                        // Progress Section (if applicable)
                        if episode.status == .current && episode.progress > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Progress")
                                        .font(.custom("JosefinSans-Medium", size: 14))

                                    Spacer()

                                    Text("\(Int(episode.progress * 100))%")
                                        .font(.custom("JosefinSans-SemiBold", size: 14))
                                        .foregroundColor(episode.status.color)
                                }

                                ProgressView(value: episode.progress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: episode.status.color))
                                    .scaleEffect(y: 2)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                        }

                        // Episode Details
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.secondary)

                                Text("Estimated Time")
                                    .font(.custom("JosefinSans-Medium", size: 14))
                                    .foregroundColor(.secondary)

                                Spacer()

                                Text(episode.estimatedTime)
                                    .font(.custom("PlayfairDisplay-Regular", size: 14))
                                    .fontWeight(.medium)
                            }

                            Divider()

                            HStack {
                                Image(systemName: episode.actionType.systemIcon)
                                    .foregroundColor(.secondary)

                                Text("Action Type")
                                    .font(.custom("JosefinSans-Medium", size: 14))
                                    .foregroundColor(.secondary)

                                Spacer()

                                Text(episode.actionTitle)
                                    .font(.custom("PlayfairDisplay-Regular", size: 14))
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Episode Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingActionSheet = true
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Action Button
                if episode.status != .locked {
                    Button {
                        handleEpisodeAction()
                    } label: {
                        HStack {
                            Image(systemName: episode.actionType.systemIcon)
                            Text(episode.actionTitle)
                                .font(.custom("JosefinSans-SemiBold", size: 16))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [episode.status.color, episode.status.color.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea()
                    )
                }
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text(episode.title),
                buttons: [
                    .default(Text("Share Episode")) {
                        // Handle share
                    },
                    .default(Text(episode.status == .current ? "Snooze" : "Set Reminder")) {
                        // Handle snooze/reminder
                    },
                    .default(Text("Pin to Top")) {
                        // Handle pin
                    },
                    .cancel()
                ]
            )
        }
    }

    private func handleEpisodeAction() {
        // Handle different episode actions
        switch episode.actionType {
        case .start:
            // Start the episode
            break
        case .`continue`:
            // Continue the episode
            break
        case .complete:
            // Complete the episode
            break
        case .review:
            // Review the episode
            break
        case .documentUpload:
            // Navigate to document upload
            break
        case .lenderConnection:
            // Navigate to lender connection
            break
        case .neighborhoodExploration:
            // Navigate to neighborhood exploration
            break
        case .propertySearch:
            // Navigate to property search
            break
        case .offerPreparation:
            // Navigate to offer preparation
            break
        case .inspectionScheduling:
            // Navigate to inspection scheduling
            break
        case .custom(_):
            // Handle custom action
            break
        }

        // Close the sheet after action
        isPresented = false
    }
}

// MARK: - Preview

struct EpisodeDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeDetailSheet(
            episode: JourneyEpisode.sampleEpisodes[0],
            isPresented: .constant(true)
        )
    }
}