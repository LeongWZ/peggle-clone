import Foundation

class PointPegSerializer {
    private let store: Store

    init(store: Store) {
        self.store = store
    }

    func serialize(_ peg: PointPegModel) -> PointPegEntity? {
        guard let boardId = peg.boardId, let pegEntity = fetchPointPeg(id: peg.id, boardId: boardId) else {
            return nil
        }

        pegEntity.xCartesian = peg.center.xCartesian
        pegEntity.yCartesian = peg.center.yCartesian
        pegEntity.radius = peg.radius
        pegEntity.heading = peg.heading

        return pegEntity
    }

    func serializeNew(_ peg: PointPegModel) -> PointPegEntity {
        let pegEntity = PointPegEntity(context: store.managedContext)
        pegEntity.id = UUID()
        pegEntity.xCartesian = peg.center.xCartesian
        pegEntity.yCartesian = peg.center.yCartesian
        pegEntity.radius = peg.radius
        pegEntity.heading = peg.heading
        return pegEntity
    }

    private func fetchPointPeg(id: UUID, boardId: UUID) -> PointPegEntity? {
        fetchPointPegsWithBoardId(boardId)
            .first { $0.id == id }
    }

    private func fetchPointPegsWithBoardId(_ boardId: UUID) -> [PointPegEntity] {
        do {
            return try store.managedContext
                .fetch(BoardEntity.fetchRequest())
                .filter { $0.id == boardId }
                .flatMap { $0.pointPegs?.allObjects as? [PointPegEntity] ?? [] }
        } catch {
            return []
        }
    }
}
