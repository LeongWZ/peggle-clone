import Foundation

extension LevelModel {
    init(levelEntity: LevelEntity) {
        id = levelEntity.id ?? UUID()
        name = levelEntity.name ?? ""

        if let boardEntity = levelEntity.board {
            board = BoardModel(boardEntity: boardEntity)
        } else {
            board = BoardModel(
                id: UUID(),
                levelId: id,
                normalPegs: [],
                pointPegs: [],
                powerUpPegs: [],
                triangularBlocks: []
            )
        }
    }
}
