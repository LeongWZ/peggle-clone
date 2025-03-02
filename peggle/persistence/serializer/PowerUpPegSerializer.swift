import Foundation

class PowerUpPegSerializer {
    private let store: Store

    init(store: Store) {
        self.store = store
    }

    func serialize(_ peg: PowerUpPegModel) -> PowerUpPegEntity? {
        guard let boardId = peg.boardId, let pegEntity = fetchPowerUpPeg(id: peg.id, boardId: boardId) else {
            return nil
        }

        pegEntity.xCartesian = peg.center.xCartesian
        pegEntity.yCartesian = peg.center.yCartesian
        pegEntity.radius = peg.radius
        pegEntity.heading = peg.heading
        return pegEntity
    }

    func serializeNew(_ peg: PowerUpPegModel) -> PowerUpPegEntity {
        let pegEntity = PowerUpPegEntity(context: store.managedContext)
        pegEntity.id = UUID()
        pegEntity.xCartesian = peg.center.xCartesian
        pegEntity.yCartesian = peg.center.yCartesian
        pegEntity.radius = peg.radius
        pegEntity.heading = peg.heading
        return pegEntity
    }

    private func fetchPowerUpPeg(id: UUID, boardId: UUID) -> PowerUpPegEntity? {
        fetchPowerUpPegsWithBoardId(boardId)
            .first { $0.id == id }
    }

    private func fetchPowerUpPegsWithBoardId(_ boardId: UUID) -> [PowerUpPegEntity] {
        do {
            return try store.managedContext
                .fetch(BoardEntity.fetchRequest())
                .filter { $0.id == boardId }
                .flatMap { $0.powerUpPegs?.allObjects as? [PowerUpPegEntity] ?? [] }
        } catch {
            return []
        }
    }
}
