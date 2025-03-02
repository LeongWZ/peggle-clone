import XCTest
@testable import peggle

class PegModelableTests: XCTestCase {

    func testWillCollideWithPeg() {
        let peg1 = MockPegModel(
            id: UUID(),
            boardId: UUID(),
            radius: 10,
            center: Position(xCartesian: 0, yCartesian: 0),
            heading: 0
        )
        let peg2 = MockPegModel(
            id: UUID(),
            boardId: UUID(),
            radius: 10,
            center: Position(xCartesian: 15, yCartesian: 0),
            heading: 0
        )

        XCTAssertTrue(peg1.willCollide(with: peg2),
                      "Pegs should collide if the distance between their centers is less than the sum of their radii")

        let peg3 = MockPegModel(
            id: UUID(),
            boardId: UUID(),
            radius: 10,
            center: Position(xCartesian: 25, yCartesian: 0),
            heading: 0
        )
        XCTAssertFalse(
            peg1.willCollide(with: peg3),
            "Pegs should not collide if the distance between their centers is greater than the sum of their radii"
        )
    }
}

// Mock class for PegModelable
struct MockPegModel: PegModelable {
    var id: UUID
    var boardId: UUID?
    var radius: Double
    var center: Position
    var heading: Double

    func addToBoard(board: BoardModel) -> BoardModel {
        board
    }

    func removeFromBoard(board: BoardModel) -> BoardModel {
        board
    }

    func moveOnBoard(board: BoardModel, to location: Position) -> (BoardModel, MockPegModel) {
        (board, self)
    }

    func rotateOnBoard(board: peggle.BoardModel, by angleRadians: Double) -> (peggle.BoardModel, MockPegModel) {
        (board, self)
    }

    func scalePegOnBoard(board: peggle.BoardModel, by scaleFactor: Double) -> (peggle.BoardModel, MockPegModel) {
        (board, self)
    }

    func render(renderer: PegRenderer) {}

    func toCircularStaticBody() -> peggle.CircularStaticBody {
        CircularStaticBody(center: center, radius: radius, restitution: 1)
    }
}
