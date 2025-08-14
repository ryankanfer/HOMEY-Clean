import SpriteKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        // scene setup...
    }

    // Fix: avoid passing SKPhysicsContact across threads.
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        DispatchQueue.main.async { [weak self] in
            self?.handleCollision(nodeA: nodeA, nodeB: nodeB)
        }
    }

    // Your collision logic here. Keep SpriteKit node work on main.
    func handleCollision(nodeA: SKNode?, nodeB: SKNode?) {
        // implement collisions safely
    }
}
