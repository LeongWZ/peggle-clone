import UIKit

class CannonView: UIImageView {
    private static let ImageName = "cannon-round"
    private static let Width: CGFloat = 90
    private static let Height: CGFloat = 100

    private weak var gameLaunchBallDelegate: GameLaunchBallDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(gameLaunchBallDelegate: GameLaunchBallDelegate?) {
        self.gameLaunchBallDelegate = gameLaunchBallDelegate

        let image = UIImage(named: CannonView.ImageName)?
            .scalePreservingAspectRatio(targetSize: CGSize(width: CannonView.Width, height: CannonView.Height))

        super.init(image: image)

        isUserInteractionEnabled = true
        initGestureRecognizers()
    }

    private func initGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCannonDrag))
        addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handleCannonDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: superview)

        if gestureRecognizer.state == .cancelled {
            transform = .identity
            return
        }

        if gestureRecognizer.state == .ended {
            gameLaunchBallDelegate?.launchBall(from: center, to: getCannonTarget(translation))
            transform = .identity
            return
        }

        let rotationAngle = getCannonRotationAngle(from: translation)
        transform = CGAffineTransform(rotationAngle: rotationAngle)
    }

    private func getCannonTarget(_ translation: CGPoint) -> CGPoint {
        CGPoint(x: center.x + translation.x, y: center.y + translation.y)
    }

    private func getCannonRotationAngle(from translation: CGPoint) -> CGFloat {
        let vector1 = CGPoint(x: 0, y: 1) // downward unit vector
        let vector2 = translation

        let dotProduct = vector1.x * vector2.x + vector1.y * vector2.y

        let magnitude1 = sqrt(vector1.x * vector1.x + vector1.y * vector1.y)
        let magnitude2 = sqrt(vector2.x * vector2.x + vector2.y * vector2.y)

        guard magnitude1 > 0, magnitude2 > 0 else {
            return 0
        }

        let angleRadians = min(acos(dotProduct / (magnitude1 * magnitude2)), CGFloat.pi / 2)

        if translation.x > 0 {
            // right hand side will have negative angle
            return -1 * angleRadians
        }

        return angleRadians
    }

}
