protocol LevelMutation {

    func createLevel(_ level: LevelModel) throws(MutationError) -> LevelModel

    func updateLevel(_ level: LevelModel) throws(MutationError) -> LevelModel

    func upsertLevel(_ level: LevelModel) throws(MutationError) -> LevelModel

    func deleteLevel(_ level: LevelModel) throws(MutationError)
}
