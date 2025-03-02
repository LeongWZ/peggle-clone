import UIKit

class BallView: UIImageView {
    private static let ImageName = "ball"

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(ball: Ball) {
        let image = UIImage(named: BallView.ImageName)?.scalePreservingAspectRatio(
            targetSize: CGSize(width: ball.radius * 2, height: ball.radius * 2))
        super.init(image: image)

        center = ball.center.toCGPoint()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if ThemeManager.getInstance().hasTheme(DarkTheme.getInstance()) {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
}

extension BallView: GameStateObserver {

    func observe(_ gameState: GameState) -> Bool {
        if !isBallInPlay(gameState) {
            removeFromSuperview()
            return false
        }

        center = gameState.activeBall?.center.toCGPoint() ?? center
        return true
    }

    private func isBallInPlay(_ gameState: GameState) -> Bool {
        gameState.activeBall != nil
    }
}
