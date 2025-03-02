import UIKit

class BucketView: UIImageView {
    private static let ImageName = "bucket"

    private let glowView = UIView()

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    init(bucket: Bucket) {
        let scaledImage = UIImage(named: BucketView.ImageName)?.resize(
            targetSize: CGSize(width: bucket.width, height: bucket.height)
        )
        super.init(image: scaledImage)
        setupGlowEffect()

        center = bucket.center.toCGPoint()
    }

    private func setupGlowEffect() {
        glowView.frame = bounds
        glowView.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        glowView.layer.cornerRadius = bounds.width / 2
        glowView.layer.shadowColor = UIColor.yellow.cgColor
        glowView.layer.shadowRadius = 20
        glowView.layer.shadowOpacity = 0.8
        glowView.layer.shadowOffset = .zero
        glowView.alpha = 0 // Initially transparent
        addSubview(glowView)
    }

    func updateEffect(hasBall: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.glowView.alpha = hasBall ? 1 : 0
        }
    }
}

extension BucketView: GameStateObserver {
    func observe(_ gameState: GameState) -> Bool {
        center = gameState.bucket.center.toCGPoint()
        updateEffect(hasBall: gameState.bucket.hasBall)
        superview?.bringSubviewToFront(self)
        return true
    }
}
