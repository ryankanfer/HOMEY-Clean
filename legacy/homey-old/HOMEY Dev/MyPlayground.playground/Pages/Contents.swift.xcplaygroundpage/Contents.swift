import PlaygroundSupport
import SwiftUI

let host = UIHostingController(rootView: RootLauncher())
host.preferredContentSize = CGSize(width: 393, height: 852)
PlaygroundPage.current.setLiveView(host)
