import SwiftUI

// ClientDashboardView has been deprecated - clients now use Signature Screens only
// This file is kept for compatibility but redirects to SignatureSceneIntegration
public struct ClientDashboardView: View {
    @EnvironmentObject private var session: AppSessionManager

    public init() {}

    public var body: some View {
        SignatureSceneIntegration()
            .environmentObject(session)
    }
}
