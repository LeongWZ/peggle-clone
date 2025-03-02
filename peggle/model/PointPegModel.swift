import Foundation

struct PointPegModel: PegModelable {
    private static let MaxRadius: Double = 80
    private static let MinRadius: Double = 20
    private static let DefaultRadius: Double = 40
    private static let DefaultHeading: Double = 0
    private static let Restitution: Double = 0.95

    let id: UUID
    let boardId: UUID?
    let center: Position
    let radius: Double
    let heading: Double

    static func ofDefault(id: UUID, boardId: UUID?, center: Position) -> PointPegModel {
        PointPegModel(
            id: id,
            boardId: boardId,
            center: center,
            radius: PointPegModel.DefaultRadius,
            heading: PointPegModel.DefaultHeading
        )
    }

    func setCenter(_ center: Position) -> PointPegModel {
        PointPegModel(
            id: id,
            boardId: boardId,
            center: center,
            radius: radius,
            heading: heading
        )
    }

    func scale(by scaleFactor: Double) -> PointPegModel {
        PointPegModel(
            id: id,
            boardId: boardId,
            center: center,
            radius: max(
                min(radius * scaleFactor, PointPegModel.MaxRadius),
                PointPegModel.MinRadius
            ),
            heading: heading
        )
    }

    func rotate(by angleRadians: Double) -> PointPegModel {
        guard !angleRadians.isNaN else {
            return self
        }

        return PointPegModel(
            id: id,
            boardId: boardId,
            center: center,
            radius: radius,
            heading: (heading + angleRadians).remainder(dividingBy: 2 * .pi)
        )
    }

    func addToBoard(board: BoardModel) -> BoardModel {
        board.addPeg(peg: self)
    }

    func removeFromBoard(board: BoardModel) -> BoardModel {
        board.removePeg(peg: self)
    }

    func moveOnBoard(board: BoardModel, to location: Position) -> (BoardModel, PointPegModel) {
        board.movePeg(pegToMove: self, movedPeg: setCenter(location))
    }

    func rotateOnBoard(board: BoardModel, by angleRadians: Double) -> (BoardModel, PointPegModel) {
        board.movePeg(pegToMove: self, movedPeg: rotate(by: angleRadians))
    }

    func scalePegOnBoard(board: BoardModel, by scaleFactor: Double) -> (BoardModel, PointPegModel) {
        board.movePeg(pegToMove: self, movedPeg: scale(by: scaleFactor))
    }

    func render(renderer: PegRenderer) {
        renderer.render(peg: self)
    }

    func toCircularStaticBody() -> CircularStaticBody {
        CircularStaticBody(
            center: center,
            radius: radius,
            restitution: PointPegModel.Restitution
        )
    }
}

// MARK: Equatable and Hashable
extension PointPegModel: Equatable, Hashable {
}
