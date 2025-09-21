
import Combine
import SpriteKit
import SwiftUI

struct GameContainerView: View {
    @StateObject private var coordinator = GameCoordinator()
    @State private var joystickVector: CGVector = .zero

    private var scene: GameScene {
        let s = GameScene(size: CGSize(width: 1920, height: 1080))
        s.scaleMode = .resizeFill
        s.gameEvents = coordinator
        return s
    }

    var body: some View {
        ZStack {
            SpriteView(scene: scene, preferredFramesPerSecond: 120)
                .ignoresSafeArea()
                .onAppear {
                    coordinator.attach(scene: scene)
                    coordinator.start()
                    coordinator.refreshTheme()
                }
                .onChange(of: coordinator.theme) { newTheme in
                    coordinator.scene?.apply(theme: newTheme)
                }
                .onChange(of: joystickVector) { v in
                    coordinator.scene?.setJoystick(vector: v)
                }

            HUDView()
                .environmentObject(coordinator)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    JoystickView(vector: $joystickVector)
                        .frame(width: 140, height: 140)
                        .padding(.trailing, 16)
                        .padding(.bottom, 22)
                }
            }
            .allowsHitTesting(true)
        }
        .sheet(isPresented: $coordinator.showEventCard) {
            EventSheetView()
                .environmentObject(coordinator)
                .presentationDetents([.fraction(0.46)])
                .presentationBackground(.thinMaterial)
        }
    }
}
