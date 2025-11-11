import SwiftUI

struct InviteAgentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var link: ClientAgentLink?
    @State private var shareURL: URL?
    @State private var isCreating = false
    @State private var acceptanceStatus: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let link, let url = shareURL {
                    VStack(spacing: 12) {
                        QRCodeView(string: url.absoluteString)
                            .frame(width: 180, height: 180)
                            .padding(8)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                        Text("Share this code with your agent")
                            .font(.headline)
                        Text(link.code)
                            .font(.title2.monospacedDigit())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.thinMaterial, in: Capsule())

                        ShareLink(item: url) {
                            Label("Share Invite", systemImage: "square.and.arrow.up")
                        }
                    }

                    if !acceptanceStatus.isEmpty {
                        Text(acceptanceStatus)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 6)
                    }
                } else {
                    if isCreating {
                        ProgressView("Creating invite...")
                    } else {
                        ContentUnavailableView(
                            "Invite not created",
                            systemImage: "qrcode",
                            description: Text("Tap Create to generate an invite")
                        )
                    }
                }

                Spacer()
            }
            .padding(16)
            .navigationTitle("Invite Agent")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") { Task { await createInvite() } }
                        .disabled(isCreating)
                }
            }
            .task { if link == nil { await createInvite() } }
        }
    }

    private func createInvite() async {
        isCreating = true
        defer { isCreating = false }
        do {
            let created = try await ClientAgentLinkRepository.shared.createInvite()
            link = created
            shareURL = ClientAgentLinkRepository.shared.shareURL(for: created.code)

            Task {
                if let _ = try await ClientAgentLinkRepository.shared.waitForAcceptance(
                    code: created.code,
                    timeout: 300,
                    interval: 2
                ) {
                    acceptanceStatus = "Connected with your agent!"
                }
            }
        } catch {
            acceptanceStatus = "Failed to create invite: \(error.localizedDescription)"
        }
    }
}

struct QRCodeView: View {
    let string: String

    var body: some View {
        if let img = generateQRCode(from: string) {
            Image(uiImage: img)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
        } else {
            Rectangle().fill(.secondary.opacity(0.2))
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 6, y: 6))
        return UIImage(ciImage: scaled)
    }
}