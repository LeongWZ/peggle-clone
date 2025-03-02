struct RefreshAction: GameAction {
    let deltaTime: Double

    func execute(state: OngoingGameState) -> GameState {
        state.refresh(deltaTime: deltaTime)
    }

    func execute(state: WonGameState) -> GameState {
        state
    }

    func execute(state: LostGameState) -> GameState {
        state
    }

    func execute(state: KaBoomGameState) -> GameState {
        state.refresh(deltaTime: deltaTime)
    }

    func execute(state: SpookyBallGameState) -> GameState {
        state.refresh(deltaTime: deltaTime)
    }
}
