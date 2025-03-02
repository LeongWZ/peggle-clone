import Foundation

struct TriangularBlockModel {
    private static let MaximumArea: Double = 150_000
    private static let DefaultPointDistanceToCenter: Double = 88
    private static let Restitution: Double = 0.95

    let id: UUID
    let boardId: UUID?
    let firstPoint: Position
    let secondPoint: Position
    let thirdPoint: Position

    var centroid: Position {
        Position(
            xCartesian: (firstPoint.xCartesian + secondPoint.xCartesian + thirdPoint.xCartesian) / 3,
            yCartesian: (firstPoint.yCartesian + secondPoint.yCartesian + thirdPoint.yCartesian) / 3
        )
    }

    init(id: UUID, boardId: UUID?, firstPoint: Position, secondPoint: Position, thirdPoint: Position) {
        self.id = id
        self.boardId = boardId
        self.firstPoint = firstPoint
        self.secondPoint = secondPoint
        self.thirdPoint = thirdPoint
    }

    static func ofDefault(centroid: Position, boardId: UUID?) -> TriangularBlockModel {
        // top point
        let firstPoint = Position(
            xCartesian: centroid.xCartesian,
            yCartesian: -1 * DefaultPointDistanceToCenter + centroid.yCartesian
        )

        // bottom left point
        let secondPoint = Position(
            xCartesian: -(sqrt(3) / 2) * DefaultPointDistanceToCenter + centroid.xCartesian,
            yCartesian: 0.5 * DefaultPointDistanceToCenter + centroid.yCartesian
        )

        // bottom right point
        let thirdPoint = Position(
            xCartesian: (sqrt(3) / 2) * DefaultPointDistanceToCenter + centroid.xCartesian,
            yCartesian: 0.5 * DefaultPointDistanceToCenter + centroid.yCartesian
        )

        return TriangularBlockModel(
            id: UUID(),
            boardId: boardId,
            firstPoint: firstPoint,
            secondPoint: secondPoint,
            thirdPoint: thirdPoint
        )
    }

    func moveOnBoard(board: BoardModel, to: Position) -> (BoardModel, TriangularBlockModel) {
        let translation = Position(
            xCartesian: to.xCartesian - centroid.xCartesian,
            yCartesian: to.yCartesian - centroid.yCartesian
        )

        let movedFirstPoint = Position(
            xCartesian: firstPoint.xCartesian + translation.xCartesian,
            yCartesian: firstPoint.yCartesian + translation.yCartesian
        )

        let movedSecondPoint = Position(
            xCartesian: secondPoint.xCartesian + translation.xCartesian,
            yCartesian: secondPoint.yCartesian + translation.yCartesian
        )

        let movedThirdPoint = Position(
            xCartesian: thirdPoint.xCartesian + translation.xCartesian,
            yCartesian: thirdPoint.yCartesian + translation.yCartesian
        )

        let movedBlock = TriangularBlockModel(
            id: id,
            boardId: boardId,
            firstPoint: movedFirstPoint,
            secondPoint: movedSecondPoint,
            thirdPoint: movedThirdPoint
        )

        return board.moveTriangularBlock(blockToMove: self, movedBlock: movedBlock)
    }

    func setFirstPoint(_ point: Position) -> TriangularBlockModel {
        let newBlock = TriangularBlockModel(
            id: id,
            boardId: boardId,
            firstPoint: point,
            secondPoint: secondPoint,
            thirdPoint: thirdPoint
        )

        guard newBlock.area <= TriangularBlockModel.MaximumArea else {
            return self
        }

        return newBlock
    }

    func setSecondPoint(_ point: Position) -> TriangularBlockModel {
        let newBlock = TriangularBlockModel(
            id: id,
            boardId: boardId,
            firstPoint: firstPoint,
            secondPoint: point,
            thirdPoint: thirdPoint
        )

        guard newBlock.area <= TriangularBlockModel.MaximumArea else {
            return self
        }

        return newBlock
    }

    func setThirdPoint(_ point: Position) -> TriangularBlockModel {
        let newBlock = TriangularBlockModel(
            id: id,
            boardId: boardId,
            firstPoint: firstPoint,
            secondPoint: secondPoint,
            thirdPoint: point
        )

        guard newBlock.area <= TriangularBlockModel.MaximumArea else {
            return self
        }

        return newBlock
    }

    func rotateOnBoard(board: BoardModel, by angleRadians: Double) -> (BoardModel, TriangularBlockModel) {
        guard !angleRadians.isNaN else {
            return (board, self)
        }

        let movedBlock = TriangularBlockModel(
            id: id,
            boardId: boardId,
            firstPoint: rotatePoint(firstPoint, by: angleRadians),
            secondPoint: rotatePoint(secondPoint, by: angleRadians),
            thirdPoint: rotatePoint(thirdPoint, by: angleRadians)
        )

        return board.moveTriangularBlock(blockToMove: self, movedBlock: movedBlock)
    }

    func willCollide(with peg: PegModelable) -> Bool {
        for point in peg.generate2DCircularMesh() where isPointInside(point: point) {
            return true
        }

        return false
    }

    func willCollide(with other: TriangularBlockModel) -> Bool {
        let isOtherTriangleInsideSelf = isPointInside(point: other.firstPoint)
            || isPointInside(point: other.secondPoint)
            || isPointInside(point: other.thirdPoint)

        let isSelfInsideOtherTriangle = other.isPointInside(point: firstPoint)
            || other.isPointInside(point: secondPoint)
            || other.isPointInside(point: thirdPoint)

        return isOtherTriangleInsideSelf || isSelfInsideOtherTriangle
    }

    func toTriangularStaticBody() -> TriangularStaticBody {
        TriangularStaticBody(
            firstPoint: firstPoint,
            secondPoint: secondPoint,
            thirdPoint: thirdPoint,
            restitution: TriangularBlockModel.Restitution
        )
    }

    func render(renderer: BlockRenderer) {
        renderer.render(block: self)
    }

    /// Source: https://stackoverflow.com/a/20861130
    private func isPointInside(point: Position) -> Bool {
        let s = (firstPoint.xCartesian - thirdPoint.xCartesian) * (point.yCartesian - thirdPoint.yCartesian)
            - (firstPoint.yCartesian - thirdPoint.yCartesian) * (point.xCartesian - thirdPoint.xCartesian)

        let t = (secondPoint.xCartesian - firstPoint.xCartesian) * (point.yCartesian - firstPoint.yCartesian)
            - (secondPoint.yCartesian - firstPoint.yCartesian) * (point.xCartesian - firstPoint.xCartesian)

        if (s < 0) != (t < 0) && s != 0 && t != 0 {
            return false
        }

        let d = (thirdPoint.xCartesian - secondPoint.xCartesian) * (point.yCartesian - secondPoint.yCartesian)
            - (thirdPoint.yCartesian - secondPoint.yCartesian) * (point.xCartesian - secondPoint.xCartesian)

        return d == 0 || (d < 0) == (s + t <= 0)
    }

    private func rotatePoint(_ point: Position, by angle: Double) -> Position {
        assert(!angle.isNaN)

        let translatedX = point.xCartesian - centroid.xCartesian
        let translatedY = point.yCartesian - centroid.yCartesian

        let rotatedX = translatedX * cos(angle) - translatedY * sin(angle)
        let rotatedY = translatedX * sin(angle) + translatedY * cos(angle)

        return Position(
            xCartesian: rotatedX + centroid.xCartesian,
            yCartesian: rotatedY + centroid.yCartesian
        )
    }
}

extension TriangularBlockModel {
    var height: Double {
        max(
            abs(firstPoint.yCartesian - secondPoint.yCartesian),
            abs(firstPoint.yCartesian - thirdPoint.yCartesian),
            abs(secondPoint.yCartesian - thirdPoint.yCartesian)
        )
    }

    var width: Double {
        max(
            abs(firstPoint.xCartesian - secondPoint.xCartesian),
            abs(firstPoint.xCartesian - thirdPoint.xCartesian),
            abs(secondPoint.xCartesian - thirdPoint.xCartesian)
        )
    }

    var leftMostPoint: Position {
        var point = firstPoint

        if secondPoint.xCartesian < point.xCartesian {
            point = secondPoint
        }

        if thirdPoint.xCartesian < point.xCartesian {
            point = thirdPoint
        }

        return point
    }

    var topMostPoint: Position {
        var point = firstPoint

        if secondPoint.yCartesian < point.yCartesian {
            point = secondPoint
        }

        if thirdPoint.yCartesian < point.yCartesian {
            point = thirdPoint
        }

        return point
    }

    var area: Double {
        0.5 * abs(firstPoint.xCartesian * (secondPoint.yCartesian - thirdPoint.yCartesian)
            + secondPoint.xCartesian * (thirdPoint.yCartesian - firstPoint.yCartesian)
            + thirdPoint.xCartesian * (firstPoint.yCartesian - secondPoint.yCartesian)
        )
    }
}

// MARK: Equatable, Hashable
extension TriangularBlockModel: Equatable, Hashable {
}
