import CoreData

class CoreDataLevelMutation: LevelMutation {
    private var store: Store
    private let levelSerializer: LevelSerializer

    init(store: Store) {
        self.store = store
        levelSerializer = LevelSerializer(store: store)
    }

    convenience init?() {
        guard let store = StoreClient() else {
            return nil
        }

        self.init(store: store)
    }

    func createLevel(_ level: LevelModel) throws(MutationError) -> LevelModel {
        let newLevelEntity = levelSerializer.serializeNew(level)

        do {
            try store.save()
        } catch {
            store.rollback()
            throw MutationError.saveFailed
        }

        return LevelModel(levelEntity: newLevelEntity)
    }

    func updateLevel(_ level: LevelModel) throws(MutationError) -> LevelModel {
        guard let levelEntity = levelSerializer.serialize(level) else {
            store.rollback()
            throw MutationError.entityNotFound
        }

        do {
            try store.save()
        } catch {
            store.rollback()
            throw MutationError.saveFailed
        }

        return LevelModel(levelEntity: levelEntity)
    }

    func upsertLevel(_ level: LevelModel) throws(MutationError) -> LevelModel {
        guard let levelEntity = levelSerializer.serialize(level) else {
            store.rollback()
            return try createLevel(level)
        }

        do {
            try store.save()
        } catch {
            store.rollback()
            throw MutationError.saveFailed
        }

        return LevelModel(levelEntity: levelEntity)
    }

    func deleteLevel(_ level: LevelModel) throws(MutationError) {
        guard let levelEntity = levelSerializer.serialize(level) else {
            store.rollback()
            throw MutationError.entityNotFound
        }

        store.delete(levelEntity)

        do {
            try store.save()
        } catch {
            store.rollback()
            throw MutationError.saveFailed
        }
    }
}
