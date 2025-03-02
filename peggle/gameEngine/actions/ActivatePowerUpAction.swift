struct ActivatePowerUpAction: GameAction {
    let powerUp: GamePowerUp

    func execute(state: OngoingGameState) -> GameState {
        powerUp.activate(state: state)
    }

    func execute(state: WonGameState) -> GameState {
        state
    }

    func execute(state: LostGameState) -> GameState {
        state
    }

    func execute(state: KaBoomGameState) -> GameState {
        powerUp.activate(state: state)
    }

    func execute(state: SpookyBallGameState) -> GameState {
        powerUp.activate(state: state)
    }
}
