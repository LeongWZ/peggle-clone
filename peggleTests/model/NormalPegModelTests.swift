import XCTest
@testable import peggle

class NormalPegModelTests: XCTestCase {

    func testInit() {
        let id = UUID()
        let boardId = UUID()
        let center = Position(xCartesian: 0, yCartesian: 0)
        let radius: Double = 32
        let heading: Double = 90
        let peg = NormalPegModel(id: id, boardId: boardId, center: center, radius: radius, heading: heading)

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
        let peg = NormalPegModel.ofDefault(
            id: UUID(),
            boardId: board.id,
            center: Position(xCartesian: 0, yCartesian: 0)
        )
        let newBoard = peg.addToBoard(board: board)

        XCTAssertEqual(newBoard.normalPegs.count, 1, "Normal pegs count should be 1 after adding the peg")
        XCTAssertEqual(newBoard.normalPegs.first, peg, "The added normal peg should be in the board")
    }

    func testRemoveFromBoard() {
        let peg = NormalPegModel.ofDefault(id: UUID(), boardId: UUID(), center: Position(xCartesian: 0, yCartesian: 0))
        let board = BoardModel(
            id: UUID(),
            levelId: UUID(),
            normalPegs: [peg],
            pointPegs: [],
            powerUpPegs: [],
            triangularBlocks: []
        )
        let newBoard = peg.removeFromBoard(board: board)

        XCTAssertTrue(newBoard.normalPegs.isEmpty, "Normal pegs should be empty after removing the peg")
    }

    func testMoveOnBoard() {
        let peg = NormalPegModel.ofDefault(id: UUID(), boardId: UUID(), center: Position(xCartesian: 0, yCartesian: 0))
        let board = BoardModel(
            id: UUID(),
            levelId: UUID(),
            normalPegs: [peg],
            pointPegs: [],
            powerUpPegs: [],
            triangularBlocks: []
        )
        let newPosition = Position(xCartesian: 1, yCartesian: 1)
        let (newBoard, movedPeg) = peg.moveOnBoard(board: board, to: newPosition)

        XCTAssertEqual(movedPeg.center, newPosition, "The moved normal peg should have the new position")
        XCTAssertEqual(newBoard.normalPegs.first?.center, newPosition,
                       "The normal peg in the board should have the new position")
    }
}
