import SwiftUI
import PlaygroundSupport

let host = UIHostingController(rootView: RootLauncher())
host.preferredContentSize = CGSize(width: 393, height: 852)
PlaygroundPage.current.setLiveView(host)
