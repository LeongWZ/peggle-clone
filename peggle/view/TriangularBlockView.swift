import UIKit

class TriangularBlockView: UIView {
    private static let PointTouchRadius: Double = 50

    private var triangularBlock: TriangularBlockModel?

    private weak var deleteTriangularBlockDelegate: LevelDesignerDeleteTriangularBlockDelegate?

    private weak var updateTriangularBlockDelegate: LevelDesignerUpdateTriangularBlockDelegate?

    private var initialCenter: CGPoint!

    private var previousTranslation: CGPoint?

    private let hasGestures: Bool

    private var triangleSublayer: CAShapeLayer?

    required init?(coder: NSCoder) {
        hasGestures = false
        super.init(coder: coder)
        self.initialCenter = center
    }

    init(triangularBlock: TriangularBlockModel,
         deleteTriangularBlockDelegate: LevelDesignerDeleteTriangularBlockDelegate?,
         updateTriangularBlockDelegate: LevelDesignerUpdateTriangularBlockDelegate?,
         hasGestures: Bool) {
        self.triangularBlock = triangularBlock
        self.deleteTriangularBlockDelegate = deleteTriangularBlockDelegate
        self.updateTriangularBlockDelegate = updateTriangularBlockDelegate
        self.hasGestures = hasGestures

        super.init(frame: CGRect(
            x: triangularBlock.leftMostPoint.xCartesian, y: triangularBlock.topMostPoint.yCartesian,
            width: triangularBlock.width, height: triangularBlock.height
        ))

        initialCenter = center
        resizeView(block: triangularBlock)

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

        tapGestureRecognizer.require(toFail: longPressGestureRecognizer)
        tapGestureRecognizer.require(toFail: panGestureGestureRecognizer)
        addGestureRecognizer(tapGestureRecognizer)

        tapGestureRecognizer.require(toFail: panGestureGestureRecognizer)
        addGestureRecognizer(longPressGestureRecognizer)

        addGestureRecognizer(panGestureGestureRecognizer)
    }

    @objc func handleTap() {
        guard hasGestures, let nonNilTriangularBlock = triangularBlock else {
            removeFromSuperview()
            return
        }

        let isBlockDeleted = deleteTriangularBlockDelegate?.deleteTriangularBlockOnTap(
            triangularBlock: nonNilTriangularBlock) ?? true

        if isBlockDeleted {
            removeFromSuperview()
        }
    }

    @objc func handleLongPress() {
        guard hasGestures, let nonNilTriangularBlock = triangularBlock else {
            removeFromSuperview()
            return
        }

        deleteTriangularBlockDelegate?.deleteTriangularBlockOnLongPress(triangularBlock: nonNilTriangularBlock)
        removeFromSuperview()
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard hasGestures, let nonNilTriangularBlock = triangularBlock else {
            return
        }

        let translation = gestureRecognizer.translation(in: superview)

        let touchPoint = gestureRecognizer.location(in: superview)

        if gestureRecognizer.state == .cancelled {
            center = initialCenter
            return
        }

        if willPanGestureResizeBlock(touchPoint) {
            resizeBlock(nonNilTriangularBlock, touchPoint: touchPoint)
            return
        }

        if updateTriangularBlockDelegate?.shouldRotateBlockOnDrag ?? false {
            let rotationAngle = getRotationAngle(from: translation)
            triangularBlock = updateTriangularBlockDelegate?
                .rotateTriangularBlock(triangularBlock: nonNilTriangularBlock, by: rotationAngle)
            resizeView(block: triangularBlock)
            return
        }

        if gestureRecognizer.state == .began {
            // Save the view's original position.
            initialCenter = center
        }

        // Update the position for the .began, .changed, and .ended states]
        let newCenter = getTranslatedPoint(
            initialCenter: initialCenter,
            translation: translation,
            triangularBlock: nonNilTriangularBlock
        )

        let newCentroid = CGPoint(
            x: nonNilTriangularBlock.centroid.xCartesian + newCenter.x - center.x,
            y: nonNilTriangularBlock.centroid.yCartesian + newCenter.y - center.y
        )

        triangularBlock = updateTriangularBlockDelegate?
            .moveTriangularBlockCenter(triangularBlock: nonNilTriangularBlock, to: newCentroid)

        if triangularBlock == nonNilTriangularBlock {
            // triangularBlock not changed
            return
        }

        center = newCenter
    }

    private func getTranslatedPoint(initialCenter: CGPoint, translation: CGPoint,
                                    triangularBlock: TriangularBlockModel) -> CGPoint {
        var newXCartesian = initialCenter.x + translation.x
        var newYCartesian = initialCenter.y + translation.y

        newXCartesian = max(newXCartesian, triangularBlock.width / 2)
        newXCartesian = min(newXCartesian,
                            (superview?.frame.width ?? CGFloat(CGFLOAT_MAX)) - triangularBlock.width / 2)

        newYCartesian = max(newYCartesian, triangularBlock.height / 2)
        newYCartesian = min(newYCartesian,
                            (superview?.frame.height ?? CGFloat(CGFLOAT_MAX)) - triangularBlock.height / 2)

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

        return angleRadians
    }

    private func resizeView(block: TriangularBlockModel?) {
        guard let triangularBlock = self.triangularBlock else {
            return
        }

        frame = CGRect(
            x: triangularBlock.leftMostPoint.xCartesian, y: triangularBlock.topMostPoint.yCartesian,
            width: triangularBlock.width, height: triangularBlock.height
        )

        let triangleSubLayer = drawTriangleSubLayer(block: triangularBlock, color: UIColor.darkGray.cgColor)
        layer.addSublayer(triangleSubLayer)
        self.triangleSublayer?.removeFromSuperlayer()
        self.triangleSublayer = triangleSubLayer
    }

    private func withinFirstPoint(_ touchPoint: CGPoint) -> Bool {
        guard let block = triangularBlock else {
            return false
        }

        return withinPoint(block.firstPoint, touchPoint: touchPoint)
    }

    private func withinSecondPoint(_ touchPoint: CGPoint) -> Bool {
        guard let block = triangularBlock else {
            return false
        }

        return withinPoint(block.secondPoint, touchPoint: touchPoint)
    }

    private func withinThirdPoint(_ touchPoint: CGPoint) -> Bool {
        guard let block = triangularBlock else {
            return false
        }

        return withinPoint(block.thirdPoint, touchPoint: touchPoint)
    }

    private func withinPoint(_ point: Position, touchPoint: CGPoint) -> Bool {
        let touchPosition = Position(xCartesian: touchPoint.x, yCartesian: touchPoint.y)
        return point.getDistance(to: touchPosition) < TriangularBlockView.PointTouchRadius
    }

    private func willPanGestureResizeBlock(_ touchPoint: CGPoint) -> Bool {
        withinFirstPoint(touchPoint) || withinSecondPoint(touchPoint) || withinThirdPoint(touchPoint)
    }

    private func resizeBlock(_ block: TriangularBlockModel, touchPoint: CGPoint) {
        if withinFirstPoint(touchPoint) {
            triangularBlock = updateTriangularBlockDelegate?.moveTriangularBlockFirstPoint(
                triangularBlock: block, to: touchPoint)
            resizeView(block: triangularBlock)
            return
        }

        if withinSecondPoint(touchPoint) {
            triangularBlock = updateTriangularBlockDelegate?.moveTriangularBlockSecondPoint(
                triangularBlock: block, to: touchPoint)
            resizeView(block: triangularBlock)
            return
        }

        if withinThirdPoint(touchPoint) {
            triangularBlock = updateTriangularBlockDelegate?.moveTriangularBlockThirdPoint(
                triangularBlock: block, to: touchPoint)
            resizeView(block: triangularBlock)
            return
        }
    }
}
