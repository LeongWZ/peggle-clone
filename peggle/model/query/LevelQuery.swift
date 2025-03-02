import Foundation

protocol LevelQuery {

    func fetch() throws(QueryError) -> [LevelModel]

    func fetchOrElse(_ defaultModelObjects: [LevelModel]) -> [LevelModel]

    func fetchById(_ id: UUID) throws(QueryError) -> LevelModel?

    func fetchByIdOrElse(_ id: UUID, _ defaultModelObject: LevelModel) -> LevelModel
}

extension LevelQuery {
    func fetchWithPreloadedLevels(boundaryWidth: Double, boundaryHeight: Double) throws(QueryError) -> [LevelModel] {
        try fetch() + PreloadedLevelsHelper.getPreloadedLevels(
            boundaryWidth: boundaryWidth, boundaryHeight: boundaryHeight)
    }

    func fetchOrElseWithPreloadedLevels(_ defaultLevels: [LevelModel], boundaryWidth: Double,
                                        boundaryHeight: Double) -> [LevelModel] {
        fetchOrElse(defaultLevels) + PreloadedLevelsHelper.getPreloadedLevels(
            boundaryWidth: boundaryWidth, boundaryHeight: boundaryHeight)
    }

    func fetchByIdWithPreloadedLevels(_ id: UUID, boundaryWidth: Double, boundaryHeight: Double)
        throws(QueryError) -> LevelModel? {
            try fetchWithPreloadedLevels(boundaryWidth: boundaryWidth, boundaryHeight: boundaryHeight).first {
                $0.id == id
            }
    }

    func fetchByIdOrElseWithPreloadedLevels(_ id: UUID, _ defaultModelObject: LevelModel,
                                            boundaryWidth: Double, boundaryHeight: Double) -> LevelModel {
        (try? fetchByIdWithPreloadedLevels(id, boundaryWidth: boundaryWidth, boundaryHeight: boundaryHeight))
            ?? defaultModelObject
    }
}
