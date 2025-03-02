import Foundation

struct NormalPegModel: PegModelable {
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

    static func ofDefault(id: UUID, boardId: UUID?, center: Position) -> NormalPegModel {
        NormalPegModel(
            id: id,
            boardId: boardId,
            center: center,
            radius: NormalPegModel.DefaultRadius,
            heading: NormalPegModel.DefaultHeading
        )
    }

    func setCenter(_ center: Position) -> NormalPegModel {
        NormalPegModel(
            id: id,
            boardId: boardId,
            center: center,
            radius: radius,
            heading: heading
        )
    }

    func scale(by scaleFactor: Double) -> NormalPegModel {
        NormalPegModel(
            id: id,
            boardId: boardId,
            center: center,
            radius: max(
                min(radius * scaleFactor, NormalPegModel.MaxRadius),
                NormalPegModel.MinRadius
            ),
            heading: heading
        )
    }

    func rotate(by angleRadians: Double) -> NormalPegModel {
        guard !angleRadians.isNaN else {
            return self
        }

        return NormalPegModel(
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

    func moveOnBoard(board: BoardModel, to location: Position) -> (BoardModel, NormalPegModel) {
        board.movePeg(pegToMove: self, movedPeg: setCenter(location))
    }

    func rotateOnBoard(board: BoardModel, by angleRadians: Double) -> (BoardModel, NormalPegModel) {
        board.movePeg(pegToMove: self, movedPeg: rotate(by: angleRadians))
    }

    func scalePegOnBoard(board: BoardModel, by scaleFactor: Double) -> (BoardModel, NormalPegModel) {
        board.movePeg(pegToMove: self, movedPeg: scale(by: scaleFactor))
    }

    func render(renderer: PegRenderer) {
        renderer.render(peg: self)
    }

    func toCircularStaticBody() -> CircularStaticBody {
        CircularStaticBody(
            center: center,
            radius: radius,
            restitution: NormalPegModel.Restitution
        )
    }
}

// MARK: Equatable and Hashable
extension NormalPegModel: Equatable, Hashable {
}
