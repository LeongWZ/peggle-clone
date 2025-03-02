import UIKit

extension UIView {
    func drawTriangleSubLayer(block: TriangularBlockModel, color: CGColor) -> CAShapeLayer {
        assert(!block.firstPoint.xCartesian.isNaN && !block.firstPoint.xCartesian.isNaN)
        assert(!block.secondPoint.xCartesian.isNaN && !block.secondPoint.yCartesian.isNaN)
        assert(!block.thirdPoint.xCartesian.isNaN && !block.thirdPoint.yCartesian.isNaN)

        let path = UIBezierPath()
        let topLeftPoint = Position(
            xCartesian: block.leftMostPoint.xCartesian,
            yCartesian: block.topMostPoint.yCartesian
        )

        let firstPoint = getRelativePosition(block.firstPoint, from: topLeftPoint).toCGPoint()
        let secondPoint = getRelativePosition(block.secondPoint, from: topLeftPoint).toCGPoint()
        let thirdPoint = getRelativePosition(block.thirdPoint, from: topLeftPoint).toCGPoint()

        path.move(to: firstPoint)
        path.addLine(to: secondPoint)
        path.addLine(to: thirdPoint)
        path.close() // Ensure the shape is properly filled

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round

        return shapeLayer
    }

    private func getRelativePosition(_ position: Position, from point: Position) -> Position {
        Position(
            xCartesian: position.xCartesian - point.xCartesian,
            yCartesian: position.yCartesian - point.yCartesian
        )
    }
}
