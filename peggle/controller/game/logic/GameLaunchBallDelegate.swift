import UIKit

protocol GameLaunchBallDelegate: AnyObject {
    func launchBall(from source: CGPoint, to target: CGPoint)
}
