import Foundation

class BoardSerializer {
    private let store: Store
    private let normalPegSerializer: NormalPegSerializer
    private let pointPegSerializer: PointPegSerializer
    private let powerUpPegSerializer: PowerUpPegSerializer
    private let triangularBlockSerializer: TriangularBlockSerializer

    init(store: Store) {
        self.store = store
        self.normalPegSerializer = NormalPegSerializer(store: store)
        self.pointPegSerializer = PointPegSerializer(store: store)
        self.powerUpPegSerializer = PowerUpPegSerializer(store: store)
        self.triangularBlockSerializer = TriangularBlockSerializer(store: store)
    }

    func serialize(_ board: BoardModel) -> BoardEntity? {
        guard let boardEntity = fetchBoard(id: board.id) else {
            return nil
        }

        serializeNormalPegs(pegs: board.normalPegs, on: boardEntity)
        serializePointPegs(pegs: board.pointPegs, on: boardEntity)
        serializePowerUpPegs(pegs: board.powerUpPegs, on: boardEntity)
        serializeTriangularBlocks(triangularBlocks: board.triangularBlocks, on: boardEntity)

        return boardEntity
    }

    func serializeNew(_ board: BoardModel) -> BoardEntity {
        let boardEntity = BoardEntity(context: store.managedContext)

        boardEntity.id = UUID()

        serializeNewNormalPegs(pegs: board.normalPegs, on: boardEntity)
        serializeNewPointPegs(pegs: board.pointPegs, on: boardEntity)
        serializeNewPowerUpPegs(pegs: board.powerUpPegs, on: boardEntity)
        serializeNewTriangularBlocks(triangularBlocks: board.triangularBlocks, on: boardEntity)

        return boardEntity
    }

    private func fetchBoard(id: UUID) -> BoardEntity? {
        try? store.managedContext
            .fetch(BoardEntity.fetchRequest())
            .first(where: { $0.id == id })
    }

    private func serializeNormalPegs(pegs: [NormalPegModel], on boardEntity: BoardEntity) {
        var updatedOrAddedPegEntities: Set<NormalPegEntity> = []

        for peg in pegs {
            if let pegEntity = normalPegSerializer.serialize(peg) {
                updatedOrAddedPegEntities.insert(pegEntity)
                continue
            }

            let newPegEntity = normalPegSerializer.serializeNew(peg)
            boardEntity.addToNormalPegs(newPegEntity)
            updatedOrAddedPegEntities.insert(newPegEntity)
        }

        for pegEntity in (boardEntity.normalPegs?.allObjects as? [NormalPegEntity] ?? []) {
            if updatedOrAddedPegEntities.contains(pegEntity) {
                continue
            }
            boardEntity.removeFromNormalPegs(pegEntity)
        }
    }

    private func serializeNewNormalPegs(pegs: [NormalPegModel], on boardEntity: BoardEntity) {
        for peg in pegs {
            let newPegEntity = normalPegSerializer.serializeNew(peg)
            boardEntity.addToNormalPegs(newPegEntity)
        }
    }

    private func serializePointPegs(pegs: [PointPegModel], on boardEntity: BoardEntity) {
        var updatedOrAddedPegEntities: Set<PointPegEntity> = []

        for peg in pegs {
            if let pegEntity = pointPegSerializer.serialize(peg) {
                updatedOrAddedPegEntities.insert(pegEntity)
                continue
            }

            let newPegEntity = pointPegSerializer.serializeNew(peg)
            boardEntity.addToPointPegs(newPegEntity)
            updatedOrAddedPegEntities.insert(newPegEntity)
        }

        for pegEntity in (boardEntity.pointPegs?.allObjects as? [PointPegEntity] ?? []) {
            if updatedOrAddedPegEntities.contains(pegEntity) {
                continue
            }
            boardEntity.removeFromPointPegs(pegEntity)
        }
    }

    private func serializeNewPointPegs(pegs: [PointPegModel], on boardEntity: BoardEntity) {
        for peg in pegs {
            let newPegEntity = pointPegSerializer.serializeNew(peg)
            boardEntity.addToPointPegs(newPegEntity)
        }
    }

    private func serializePowerUpPegs(pegs: [PowerUpPegModel], on boardEntity: BoardEntity) {
        var updatedOrAddedPegEntities: Set<PowerUpPegEntity> = []

        for peg in pegs {
            if let pegEntity = powerUpPegSerializer.serialize(peg) {
                updatedOrAddedPegEntities.insert(pegEntity)
                continue
            }

            let newPegEntity = powerUpPegSerializer.serializeNew(peg)
            boardEntity.addToPowerUpPegs(newPegEntity)
            updatedOrAddedPegEntities.insert(newPegEntity)
        }

        for pegEntity in (boardEntity.powerUpPegs?.allObjects as? [PowerUpPegEntity] ?? []) {
            if updatedOrAddedPegEntities.contains(pegEntity) {
                continue
            }
            boardEntity.removeFromPowerUpPegs(pegEntity)
        }
    }

    private func serializeNewPowerUpPegs(pegs: [PowerUpPegModel], on boardEntity: BoardEntity) {
        for peg in pegs {
            let newPegEntity = powerUpPegSerializer.serializeNew(peg)
            boardEntity.addToPowerUpPegs(newPegEntity)
        }
    }

    private func serializeTriangularBlocks(triangularBlocks: [TriangularBlockModel], on boardEntity: BoardEntity) {
        var updatedOrAddedBlockEntities: Set<TriangularBlockEntity> = []

        for triangularBlock in triangularBlocks {
            if let triangularBlockEntity = triangularBlockSerializer.serialize(triangularBlock) {
                updatedOrAddedBlockEntities.insert(triangularBlockEntity)
                continue
            }

            let newTriangularBlockEntity = triangularBlockSerializer.serializeNew(triangularBlock)
            boardEntity.addToTriangularBlocks(newTriangularBlockEntity)
            updatedOrAddedBlockEntities.insert(newTriangularBlockEntity)
        }

        for triangularBlockEntity in (boardEntity.triangularBlocks?.allObjects as? [TriangularBlockEntity] ?? []) {
            if updatedOrAddedBlockEntities.contains(triangularBlockEntity) {
                continue
            }
            boardEntity.removeFromTriangularBlocks(triangularBlockEntity)
        }
    }

    private func serializeNewTriangularBlocks(triangularBlocks: [TriangularBlockModel], on boardEntity: BoardEntity) {
        for triangularBlock in triangularBlocks {
            let newTriangularBlockEntity = triangularBlockSerializer.serializeNew(triangularBlock)
            boardEntity.addToTriangularBlocks(newTriangularBlockEntity)
        }
    }
}
