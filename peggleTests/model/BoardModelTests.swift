import XCTest
@testable import peggle

class BoardModelTests: XCTestCase {

    func testResetBoard() {
        let board = BoardModel(
            id: UUID(),
            levelId: nil,
            normalPegs: [
                NormalPegModel.ofDefault(id: UUID(), boardId: UUID(), center: Position(xCartesian: 0, yCartesian: 0))
            ],
            pointPegs: [
                PointPegModel.ofDefault(id: UUID(), boardId: UUID(), center: Position(xCartesian: 1, yCartesian: 1))
            ],
            powerUpPegs: [], triangularBlocks: []
        )
        let resetBoard = board.reset()

        XCTAssertTrue(resetBoard.normalPegs.isEmpty, "Normal pegs should be empty after reset")
        XCTAssertTrue(resetBoard.pointPegs.isEmpty, "Point pegs should be empty after reset")
    }

    func testAddNormalPeg() {
        let board = BoardModel(
            id: UUID(),
            levelId: nil,
            normalPegs: [],
            pointPegs: [],
            powerUpPegs: [],
            triangularBlocks: []
        )
        let peg = NormalPegModel.ofDefault(id: UUID(), boardId: board.id, center: Position(xCartesian: 0, yCartesian: 0))
        let newBoard = board.addPeg(peg: peg)

        XCTAssertEqual(newBoard.normalPegs.count, 1, "Normal pegs count should be 1 after adding a peg")
        XCTAssertEqual(newBoard.normalPegs.first, peg, "The added normal peg should be in the board")
    }

    func testAddPointPeg() {
        let board = BoardModel(
            id: UUID(),
            levelId: nil,
            normalPegs: [],
            pointPegs: [],
            powerUpPegs: [],
            triangularBlocks: []
        )
        let peg = PointPegModel.ofDefault(id: UUID(), boardId: board.id, center: Position(xCartesian: 0, yCartesian: 0))
        let newBoard = board.addPeg(peg: peg)

        XCTAssertEqual(newBoard.pointPegs.count, 1, "Point pegs count should be 1 after adding a peg")
        XCTAssertEqual(newBoard.pointPegs.first, peg, "The added point peg should be in the board")
    }

    func testRemoveNormalPeg() {
        let peg = NormalPegModel.ofDefault(id: UUID(), boardId: UUID(), center: Position(xCartesian: 0, yCartesian: 0))
        let board = BoardModel(
            id: UUID(),
            levelId: nil,
            normalPegs: [peg],
            pointPegs: [],
            powerUpPegs: [],
            triangularBlocks: []
        )
        let newBoard = board.removePeg(peg: peg)

        XCTAssertTrue(newBoard.normalPegs.isEmpty, "Normal pegs should be empty after removing the peg")
    }

    func testRemovePointPeg() {
        let peg = PointPegModel.ofDefault(id: UUID(), boardId: UUID(), center: Position(xCartesian: 0, yCartesian: 0))
        let board = BoardModel(
            id: UUID(),
            levelId: nil,
            normalPegs: [],
            pointPegs: [peg],
            powerUpPegs: [],
            triangularBlocks: []
        )
        let newBoard = board.removePeg(peg: peg)

        XCTAssertTrue(newBoard.pointPegs.isEmpty, "Point pegs should be empty after removing the peg")
    }

    func testMoveNormalPeg() {
        let peg = NormalPegModel.ofDefault(id: UUID(), boardId: UUID(), center: Position(xCartesian: 0, yCartesian: 0))
        let board = BoardModel(
            id: UUID(),
            levelId: nil,
            normalPegs: [peg],
            pointPegs: [],
            powerUpPegs: [],
            triangularBlocks: []
        )
        let newPosition = Position(xCartesian: 1, yCartesian: 1)
        let (newBoard, movedPeg) = board.movePeg(pegToMove: peg, movedPeg: peg.setCenter(newPosition))

        XCTAssertEqual(movedPeg.center, newPosition, "The moved normal peg should have the new position")
        XCTAssertEqual(newBoard.normalPegs.first?.center, newPosition,
                       "The normal peg in the board should have the new position")
    }

    func testMovePointPeg() {
        let peg = PointPegModel.ofDefault(id: UUID(), boardId: UUID(), center: Position(xCartesian: 0, yCartesian: 0))
        let board = BoardModel(
            id: UUID(),
            levelId: nil,
            normalPegs: [],
            pointPegs: [peg],
            powerUpPegs: [],
            triangularBlocks: []
        )
        let newPosition = Position(xCartesian: 1, yCartesian: 1)
        let (newBoard, movedPeg) = board.movePeg(pegToMove: peg, movedPeg: peg.setCenter(newPosition))

        XCTAssertEqual(movedPeg.center, newPosition, "The moved point peg should have the new position")
        XCTAssertEqual(newBoard.pointPegs.first?.center, newPosition,
                       "The point peg in the board should have the new position")
    }
}
