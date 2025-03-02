import XCTest
@testable import peggle

class LevelModelTests: XCTestCase {

    func testInitWithBoard() {
        let board = BoardModel(
            id: UUID(),
            levelId: UUID(),
            normalPegs: [],
            pointPegs: [],
            powerUpPegs: [],
            triangularBlocks: []
        )
        let level = LevelModel(id: UUID(), name: "Test Level", board: board)

        XCTAssertEqual(level.name, "Test Level", "Level name should be 'Test Level'")
        XCTAssertEqual(level.board, board, "Level board should be the same as the initialized board")
    }

    func testInitWithoutBoard() {
        let level = LevelModel(id: UUID(), name: "Test Level")

        XCTAssertEqual(level.name, "Test Level", "Level name should be 'Test Level'")
        XCTAssertEqual(level.board.normalPegs.count, 0, "Level board should have no normal pegs")
        XCTAssertEqual(level.board.pointPegs.count, 0, "Level board should have no point pegs")
    }

    func testSetName() {
        let level = LevelModel(id: UUID(), name: "Old Name")
        let newLevel = level.setName("New Name")

        XCTAssertEqual(newLevel.name, "New Name", "Level name should be updated to 'New Name'")
        XCTAssertEqual(newLevel.id, level.id, "Level id should remain the same")
        XCTAssertEqual(newLevel.board, level.board, "Level board should remain the same")
    }

    func testSetBoard() {
        let oldBoard = BoardModel(
            id: UUID(),
            levelId: UUID(),
            normalPegs: [],
            pointPegs: [],
            powerUpPegs: [],
            triangularBlocks: []
        )
        let newBoard = BoardModel(
            id: UUID(),
            levelId: UUID(),
            normalPegs: [
                NormalPegModel.ofDefault(id: UUID(), boardId: UUID(), center: Position(xCartesian: 0, yCartesian: 0))
            ],
            pointPegs: [], powerUpPegs: [], triangularBlocks: []
        )
        let level = LevelModel(id: UUID(), name: "Test Level", board: oldBoard)
        let newLevel = level.setBoard(newBoard)

        XCTAssertEqual(newLevel.board, newBoard, "Level board should be updated to the new board")
        XCTAssertEqual(newLevel.id, level.id, "Level id should remain the same")
        XCTAssertEqual(newLevel.name, level.name, "Level name should remain the same")
    }
}
