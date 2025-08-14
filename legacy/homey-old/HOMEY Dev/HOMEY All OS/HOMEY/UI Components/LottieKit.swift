//  LottieLoopMode.swift
//  HOMEY

import SwiftUI

// Rename so it doesn't collide with Lottie’s type
public enum LoopBehavior {
    case playOnce
    case loop
    case autoReverse
}

public struct LottieView: View {
    private let name: String
    private let loopMode: LoopBehavior
    private let speed: CGFloat

    public init(name: String, loopMode: LoopBehavior = .loop, speed: CGFloat = 1.0) {
        self.name = name
        self.loopMode = loopMode
        self.speed = speed
    }

    public var body: some View {
        #if canImport(Lottie)
        LottieBackedView(name: name, loopMode: loopMode, speed: speed)
        #else
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial)
            VStack(spacing: 8) {
                ProgressView()
                Text("Animation “\(name)”")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
}

#if canImport(Lottie)
import Lottie
import UIKit

fileprivate struct LottieBackedView: UIViewRepresentable {
    let name: String
    let loopMode: LoopBehavior
    let speed: CGFloat

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false

        let animationView = LottieAnimationView()
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.animation = loadAnimation(named: name)
        animationView.animationSpeed = speed
        animationView.loopMode = map(loopMode)          // now Lottie’s enum

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if animationView.animation != nil {
            animationView.play()
        }
        context.coordinator.animationView = animationView
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if context.coordinator.currentName != name {
            context.coordinator.currentName = name
            let anim = loadAnimation(named: name)
            context.coordinator.animationView?.animation = anim
            if anim != nil { context.coordinator.animationView?.play() }
        }
        context.coordinator.animationView?.loopMode = map(loopMode)   // Lottie’s enum
        context.coordinator.animationView?.animationSpeed = speed
    }

    func makeCoordinator() -> Coordinator { Coordinator(currentName: name) }

    final class Coordinator {
        var currentName: String
        weak var animationView: LottieAnimationView?
        init(currentName: String) { self.currentName = currentName }
    }

    private func loadAnimation(named: String) -> LottieAnimation? {
        if let url = Bundle.main.url(forResource: named, withExtension: "json") {
            return LottieAnimation.filepath(url.path)
        }
        if let url = Bundle.main.url(forResource: named, withExtension: "lottie") {
            return LottieAnimation.filepath(url.path)
        }
        return nil
    }

    // Explicitly map our enum to Lottie’s namespaced type
    private func map(_ mode: LoopBehavior) -> Lottie.LottieLoopMode {
        switch mode {
        case .playOnce:    return .playOnce
        case .loop:        return .loop
        case .autoReverse: return .autoReverse
        }
    }
}
#endif
