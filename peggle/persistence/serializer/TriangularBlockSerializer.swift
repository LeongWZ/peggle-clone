import Foundation

class TriangularBlockSerializer {
    private let store: Store

    init(store: Store) {
        self.store = store
    }

    func serialize(_ triangularBlock: TriangularBlockModel) -> TriangularBlockEntity? {
        guard let boardId = triangularBlock.boardId,
              let triangularBlockEntity = fetchTriangularBlock(id: triangularBlock.id, boardId: boardId) else {
            return nil
        }

        triangularBlockEntity.firstXCartesian = triangularBlock.firstPoint.xCartesian
        triangularBlockEntity.firstYCartesian = triangularBlock.firstPoint.yCartesian

        triangularBlockEntity.secondXCartesian = triangularBlock.secondPoint.xCartesian
        triangularBlockEntity.secondYCartesian = triangularBlock.secondPoint.yCartesian

        triangularBlockEntity.thirdXCartesian = triangularBlock.thirdPoint.xCartesian
        triangularBlockEntity.thirdYCartesian = triangularBlock.thirdPoint.yCartesian

        return triangularBlockEntity
    }

    func serializeNew(_ triangularBlock: TriangularBlockModel) -> TriangularBlockEntity {
        let triangularBlockEntity = TriangularBlockEntity(context: store.managedContext)
        triangularBlockEntity.id = UUID()

        triangularBlockEntity.firstXCartesian = triangularBlock.firstPoint.xCartesian
        triangularBlockEntity.firstYCartesian = triangularBlock.firstPoint.yCartesian

        triangularBlockEntity.secondXCartesian = triangularBlock.secondPoint.xCartesian
        triangularBlockEntity.secondYCartesian = triangularBlock.secondPoint.yCartesian

        triangularBlockEntity.thirdXCartesian = triangularBlock.thirdPoint.xCartesian
        triangularBlockEntity.thirdYCartesian = triangularBlock.thirdPoint.yCartesian

        return triangularBlockEntity
    }

    private func fetchTriangularBlock(id: UUID, boardId: UUID) -> TriangularBlockEntity? {
        fetchTriangularBlocksWithBoardId(boardId)
            .first { $0.id == id }
    }

    private func fetchTriangularBlocksWithBoardId(_ boardId: UUID) -> [TriangularBlockEntity] {
        do {
            return try store.managedContext
                .fetch(BoardEntity.fetchRequest())
                .filter { $0.id == boardId }
                .flatMap { $0.triangularBlocks?.allObjects as? [TriangularBlockEntity] ?? [] }
        } catch {
            return []
        }
    }
}
