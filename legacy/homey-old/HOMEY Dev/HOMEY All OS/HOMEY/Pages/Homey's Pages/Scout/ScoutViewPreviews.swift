import SwiftUI

#if canImport(SwiftUI) && DEBUG
    struct ScoutView_Previews: PreviewProvider {
        static var previews: some View {
            ScoutView()
                .environmentObject(SessionManager())
                .environmentObject(AppState())
                .environmentObject(EducationCenterStore())
                .environmentObject(TasteStore())
        }
    }
#endif
