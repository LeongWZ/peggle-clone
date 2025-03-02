import Foundation

extension BoardModel {

    init(boardEntity: BoardEntity) {
        let id = boardEntity.id ?? UUID()
        let levelId = boardEntity.level?.id

        let normalPegs = boardEntity.normalPegs?.allObjects
            .compactMap { pegEntity in pegEntity as? NormalPegEntity }
            .map(NormalPegModel.init) ?? []
        let pointPegs = boardEntity.pointPegs?.allObjects
            .compactMap { pegEntity in pegEntity as? PointPegEntity }
            .map(PointPegModel.init) ?? []
        let powerUpPegs = boardEntity.powerUpPegs?.allObjects
            .compactMap { pegEntity in pegEntity as? PowerUpPegEntity }
            .map(PowerUpPegModel.init) ?? []
        let triangularBlocks = boardEntity.triangularBlocks?.allObjects
            .compactMap { triangularBlockEntity in triangularBlockEntity as? TriangularBlockEntity }
            .map(TriangularBlockModel.init) ?? []

        self.init(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs,
            pointPegs: pointPegs,
            powerUpPegs: powerUpPegs,
            triangularBlocks: triangularBlocks
        )
    }
}
