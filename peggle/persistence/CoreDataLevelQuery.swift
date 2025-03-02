import CoreData

class CoreDataLevelQuery: LevelQuery {
    private let store: Store

    init(store: Store) {
        self.store = store
    }

    convenience init?() {
        guard let store = StoreClient() else {
            return nil
        }

        self.init(store: store)
    }

    func fetch() throws(QueryError) -> [LevelModel] {
        do {
            return try store.managedContext
                .fetch(LevelEntity.fetchRequest())
                .map(LevelModel.init)
        } catch {
            throw QueryError.queryNotFound
        }
    }

    func fetchOrElse(_ defaultModelObjects: [LevelModel]) -> [LevelModel] {
        guard let objects = try? fetch() else {
            return defaultModelObjects
        }

        return objects
    }

    func fetchById(_ id: UUID) throws(QueryError) -> LevelModel? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let request = LevelEntity.fetchRequest()
        request.predicate = predicate

        do {
            return try store.managedContext
                .fetch(request)
                .map(LevelModel.init)
                .first
        } catch {
            throw QueryError.queryNotFound
        }
    }

    func fetchByIdOrElse(_ id: UUID, _ defaultModelObject: LevelModel) -> LevelModel {
        guard let object = try? fetchById(id) else {
            return defaultModelObject
        }

        return object
    }
}
