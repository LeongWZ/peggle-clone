protocol GameAction {
    func execute(state: OngoingGameState) -> GameState

    func execute(state: WonGameState) -> GameState

    func execute(state: LostGameState) -> GameState

    func execute(state: KaBoomGameState) -> GameState

    func execute(state: SpookyBallGameState) -> GameState
}
