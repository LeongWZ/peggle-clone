import XCTest
@testable import peggle

class PowerUpPegModelTests: XCTestCase {

    func testInit() {
        let id = UUID()
        let boardId = UUID()
        let center = Position(xCartesian: 0, yCartesian: 0)
        let radius: Double = 32
        let heading: Double = 90
        let peg = PowerUpPegModel(id: id, boardId: boardId, center: center, radius: radius, heading: heading)

        XCTAssertEqual(peg.id, id, "Peg id should be the same as the initialized id")
        XCTAssertEqual(peg.boardId, boardId, "Peg boardId should be the same as the initialized boardId")
        XCTAssertEqual(peg.center, center, "Peg center should be the same as the initialized center")
        XCTAssertEqual(peg.radius, 32, "Peg radius should be 32")
    }

    func testAddToBoard() {
        let board = BoardModel(
            id: UUID(),
            levelId: UUID(),
            normalPegs: [],
            pointPegs: [],
            powerUpPegs: [],
            triangularBlocks: []
        )
        let peg = PowerUpPegModel.ofDefault(
            id: UUID(),
            boardId: board.id,
            center: Position(xCartesian: 0, yCartesian: 0)
        )
        let newBoard = peg.addToBoard(board: board)

        XCTAssertEqual(newBoard.powerUpPegs.count, 1, "Power Up pegs count should be 1 after adding the peg")
        XCTAssertEqual(newBoard.powerUpPegs.first, peg, "The added power up peg should be in the board")
    }

    func testRemoveFromBoard() {
        let peg = PowerUpPegModel.ofDefault(id: UUID(), boardId: UUID(), center: Position(xCartesian: 0, yCartesian: 0))
        let board = BoardModel(
            id: UUID(),
            levelId: UUID(),
            normalPegs: [],
            pointPegs: [],
            powerUpPegs: [peg],
            triangularBlocks: []
        )
        let newBoard = peg.removeFromBoard(board: board)

        XCTAssertTrue(newBoard.powerUpPegs.isEmpty, "Power Up pegs should be empty after removing the peg")
    }

    func testMoveOnBoard() {
        let peg = PowerUpPegModel.ofDefault(id: UUID(), boardId: UUID(), center: Position(xCartesian: 0, yCartesian: 0))
        let board = BoardModel(
            id: UUID(),
            levelId: UUID(),
            normalPegs: [],
            pointPegs: [],
            powerUpPegs: [peg],
            triangularBlocks: []
        )
        let newPosition = Position(xCartesian: 1, yCartesian: 1)
        let (newBoard, movedPeg) = peg.moveOnBoard(board: board, to: newPosition)

        XCTAssertEqual(movedPeg.center, newPosition, "The moved power up peg should have the new position")
        XCTAssertEqual(newBoard.powerUpPegs.first?.center, newPosition,
                       "The power up peg in the board should have the new position")
    }
}
