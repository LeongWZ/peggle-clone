import UIKit

class PegView: UIImageView {
    private static let ExplosionImageName = "explosion"
    private var peg: PegModelable?

    private weak var deletePegDelegate: LevelDesignerDeletePegDelegate?

    private weak var updatePegDelegate: LevelDesignerUpdatePegDelegate?

    private var initialCenter: CGPoint!

    private var previousTranslation: CGPoint?

    private let hasGestures: Bool

    private var heading: CGFloat {
        CGFloat(atan2f(Float(transform.b), Float(transform.a)))
    }

    required init?(coder: NSCoder) {
        hasGestures = false
        super.init(coder: coder)
        self.initialCenter = center
    }

    init(peg: PegModelable, image: UIImage?, highlightedImage: UIImage?,
         deletePegDelegate: LevelDesignerDeletePegDelegate?,
         updatePegDelegate: LevelDesignerUpdatePegDelegate?, hasGestures: Bool) {
        self.hasGestures = hasGestures
        self.peg = peg
        self.deletePegDelegate = deletePegDelegate
        self.updatePegDelegate = updatePegDelegate

        let scaledImage = image?.scalePreservingAspectRatio(
            targetSize: CGSize(width: peg.radius * 2, height: peg.radius * 2))
        let scaledHighlightedImage = highlightedImage?.scalePreservingAspectRatio(
            targetSize: CGSize(width: peg.radius * 2, height: peg.radius * 2))

        super.init(image: scaledImage, highlightedImage: scaledHighlightedImage)

        center = peg.center.toCGPoint()
        transform = transform.rotated(by: peg.heading)

        clipsToBounds = true
        isUserInteractionEnabled = true

        if hasGestures {
            initGestureRecognizers()
        }
    }

    private func initGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        let panGestureGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))

        tapGestureRecognizer.require(toFail: longPressGestureRecognizer)
        tapGestureRecognizer.require(toFail: panGestureGestureRecognizer)
        addGestureRecognizer(tapGestureRecognizer)

        tapGestureRecognizer.require(toFail: panGestureGestureRecognizer)
        addGestureRecognizer(longPressGestureRecognizer)

        addGestureRecognizer(panGestureGestureRecognizer)

        pinchGestureRecognizer.require(toFail: panGestureGestureRecognizer)
        addGestureRecognizer(pinchGestureRecognizer)
    }

    @objc func handleTap() {
        guard hasGestures, let nonNilPeg = peg else {
            removeFromSuperview()
            return
        }

        let isPegDeleted = deletePegDelegate?.deletePegOnTap(peg: nonNilPeg) ?? true

        if isPegDeleted {
            removeFromSuperview()
        }
    }

    @objc func handleLongPress() {
        guard hasGestures, let nonNilPeg = peg else {
            removeFromSuperview()
            return
        }

        deletePegDelegate?.deletePegOnLongPress(peg: nonNilPeg)
        removeFromSuperview()
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard hasGestures, let nonNilPeg = peg else {
            return
        }

        let translation = gestureRecognizer.translation(in: superview)

        if gestureRecognizer.state == .cancelled {
            center = initialCenter
            return
        }

        if updatePegDelegate?.shouldRotatePegOnDrag ?? false {
            let rotationAngle = getRotationAngle(from: translation)
            peg = updatePegDelegate?.rotatePeg(peg: nonNilPeg, by: rotationAngle)
            transform = transform.rotated(by: rotationAngle)
            return
        }

        if gestureRecognizer.state == .began {
            // Save the view's original position.
            initialCenter = center
        }

        // Update the position for the .began, .changed, and .ended states]
        let newCenter = getTranslatedPoint(initialCenter: initialCenter, translation: translation,
                                           pegRadius: nonNilPeg.radius)

        peg = updatePegDelegate?.movePeg(peg: nonNilPeg, to: newCenter) ?? nonNilPeg
        center = peg?.center.toCGPoint() ?? center
    }

    @objc func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard hasGestures, let peg = self.peg else {
            return
        }

        if gestureRecognizer.state != .began && gestureRecognizer.state != .changed {
            return
        }

        guard let scaledPeg = updatePegDelegate?.scalePeg(peg: peg, by: gestureRecognizer.scale) else {
            return
        }

        let actualScaleFactor = scaledPeg.radius / peg.radius
        self.peg = scaledPeg
        transform = transform.scaledBy(x: actualScaleFactor, y: actualScaleFactor)

        // reset gesture scale
        gestureRecognizer.scale = 1.0
    }

    private func getTranslatedPoint(initialCenter: CGPoint, translation: CGPoint, pegRadius: Double) -> CGPoint {
        var newXCartesian = initialCenter.x + translation.x
        var newYCartesian = initialCenter.y + translation.y

        newXCartesian = max(newXCartesian, pegRadius)
        newXCartesian = min(newXCartesian, (superview?.frame.width ?? CGFloat(CGFLOAT_MAX)) - pegRadius)

        newYCartesian = max(newYCartesian, pegRadius)
        newYCartesian = min(newYCartesian, (superview?.frame.height ?? CGFloat(CGFLOAT_MAX)) - pegRadius)

        return CGPoint(x: newXCartesian, y: newYCartesian)
    }

    private func getRotationAngle(from translation: CGPoint) -> CGFloat {
        guard let previousTranslation = previousTranslation else {
            self.previousTranslation = translation
            return 0
        }

        let referenceVector = previousTranslation
        let vector = translation
        self.previousTranslation = translation

        let dotProduct = referenceVector.x * vector.x + referenceVector.y * vector.y
        let magnitude1 = sqrt(referenceVector.x * referenceVector.x + referenceVector.y * referenceVector.y)
        let magnitude2 = sqrt(vector.x * vector.x + vector.y * vector.y)

        guard magnitude1 > 0, magnitude2 > 0 else {
            return 0
        }

        var angleRadians = acos(dotProduct / (magnitude1 * magnitude2))

        // Use cross product to determine rotation direction
        let crossProduct = referenceVector.x * vector.y - referenceVector.y * vector.x

        if crossProduct < 0 {
            angleRadians = -angleRadians
        }

        if angleRadians.isNaN {
            return 0
        }

        return angleRadians
    }
}

extension PegView: GameStateObserver {

    func observe(_ gameState: GameState) -> Bool {
        if isPegDeleted(gameState) {
            removeFromSuperviewWithAnimation()
            return false
        }

        if hasPegExploded(gameState) {
            handleExplosion()
        }

        isHighlighted = hasCollidedWithBall(gameState)

        return true
    }

    private func hasCollidedWithBall(_ gameState: GameState) -> Bool {
        guard let pegId = peg?.id else {
            return false
        }

        return gameState.collidedPegs.keys.contains(pegId)
    }

    private func isPegDeleted(_ gameState: GameState) -> Bool {
        guard let pegId = peg?.id else {
            return false
        }

        return !gameState.pegs.keys.contains(pegId)
    }

    private func hasPegExploded(_ gameState: GameState) -> Bool {
        guard let pegId = peg?.id else {
            return false
        }

        return gameState.explodedPegs.keys.contains(pegId)
    }

    private func removeFromSuperviewWithAnimation() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            },
            completion: { finished in
                if finished {
                    self.removeFromSuperview()
                }
            }
        )
    }

    private func handleExplosion() {
        guard let superview = superview else {
            return
        }

        // Ensure explosion is slightly larger than peg
        let explosionSize = CGSize(width: bounds.width * 1.5, height: bounds.height * 1.5)
        let explosionImage = UIImage(named: PegView.ExplosionImageName)?
            .scalePreservingAspectRatio(targetSize: explosionSize)
        let explosionView = UIImageView(image: explosionImage)

        explosionView.center = center
        explosionView.bounds = CGRect(origin: .zero, size: explosionSize)
        superview.addSubview(explosionView)

        // Animate explosion effect
        UIView.animate(
            withDuration: 0.75,
            animations: {
                explosionView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) // Slightly enlarge explosion
                explosionView.alpha = 0 // Fade out
            },
            completion: { _ in
                explosionView.removeFromSuperview()
            }
        )
    }
}
