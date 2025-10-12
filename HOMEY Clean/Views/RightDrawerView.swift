import SwiftUI

struct RightDrawerView<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Dimmed background
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
            }

            // Drawer content
            HStack {
                Spacer()
                
                content
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                    .background(Color.black)
                    .offset(x: isPresented ? 0 : UIScreen.main.bounds.width)
                    .transition(.move(edge: .trailing))
            }
            .ignoresSafeArea()
        }
        .animation(.easeInOut, value: isPresented)
    }
}