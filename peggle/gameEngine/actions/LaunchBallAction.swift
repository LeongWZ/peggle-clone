struct LaunchBallAction: GameAction {
    let source: Position
    let target: Position
    let deltaTime: Double

    func execute(state: OngoingGameState) -> GameState {
        state.launchBall(from: source, to: target, deltaTime: deltaTime)
    }

    func execute(state: WonGameState) -> GameState {
        state
    }

    func execute(state: LostGameState) -> GameState {
        state
    }

    func execute(state: KaBoomGameState) -> GameState {
        state.launchBall(from: source, to: target, deltaTime: deltaTime)
    }

    func execute(state: SpookyBallGameState) -> GameState {
        state.launchBall(from: source, to: target, deltaTime: deltaTime)
    }
}
