import Foundation

class NormalPegSerializer {
    private let store: Store

    init(store: Store) {
        self.store = store
    }

    func serialize(_ peg: NormalPegModel) -> NormalPegEntity? {
        guard let boardId = peg.boardId, let pegEntity = fetchNormalPeg(id: peg.id, boardId: boardId) else {
            return nil
        }

        pegEntity.xCartesian = peg.center.xCartesian
        pegEntity.yCartesian = peg.center.yCartesian
        pegEntity.radius = peg.radius
        pegEntity.heading = peg.heading
        return pegEntity
    }

    func serializeNew(_ peg: NormalPegModel) -> NormalPegEntity {
        let pegEntity = NormalPegEntity(context: store.managedContext)
        pegEntity.id = UUID()
        pegEntity.xCartesian = peg.center.xCartesian
        pegEntity.yCartesian = peg.center.yCartesian
        pegEntity.radius = peg.radius
        pegEntity.heading = peg.heading
        return pegEntity
    }

    private func fetchNormalPeg(id: UUID, boardId: UUID) -> NormalPegEntity? {
        fetchNormalPegsWithBoardId(boardId)
            .first { $0.id == id }
    }

    private func fetchNormalPegsWithBoardId(_ boardId: UUID) -> [NormalPegEntity] {
        do {
            return try store.managedContext
                .fetch(BoardEntity.fetchRequest())
                .filter { $0.id == boardId }
                .flatMap { $0.normalPegs?.allObjects as? [NormalPegEntity] ?? [] }
        } catch {
            return []
        }
    }
}
