import Foundation

/// A model representing a level in the game. Each level has a unique identifier, a name, and a board.
struct LevelModel {
    let id: UUID
    let name: String
    let board: BoardModel

    init(id: UUID, name: String, board: BoardModel) {
        self.id = id
        self.name = name
        self.board = board
    }

    init(id: UUID, name: String) {
        self.id = id
        self.name = name
        board = BoardModel(
            id: UUID(),
            levelId: id,
            normalPegs: [],
            pointPegs: [],
            powerUpPegs: [],
            triangularBlocks: []
        )
    }

    func setName(_ name: String) -> LevelModel {
        LevelModel(id: id, name: name, board: board)
    }

    func setBoard(_ board: BoardModel) -> LevelModel {
        LevelModel(id: id, name: name, board: board)
    }

}

// MARK: Equatable & Hashable
extension LevelModel: Equatable, Hashable {
}
