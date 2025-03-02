import Foundation

class LevelSerializer {
    private let store: Store
    private let boardSerializer: BoardSerializer

    init(store: Store) {
        self.store = store
        boardSerializer = BoardSerializer(store: store)
    }

    func serialize(_ level: LevelModel) -> LevelEntity? {
        guard let levelEntity = fetchLevelEntity(level.id) else {
            return nil
        }

        levelEntity.name = level.name

        levelEntity.board = boardSerializer.serialize(level.board) ?? boardSerializer.serializeNew(level.board)
        return levelEntity
    }

    func serializeNew(_ level: LevelModel) -> LevelEntity {
        let levelEntity = LevelEntity(context: store.managedContext)
        levelEntity.id = UUID()
        levelEntity.name = level.name

        levelEntity.board = boardSerializer.serializeNew(level.board)
        return levelEntity
    }

    private func fetchLevelEntity(_ id: UUID) -> LevelEntity? {
        try? store.managedContext
            .fetch(LevelEntity.fetchRequest())
            .first { $0.id == id }
    }
}
