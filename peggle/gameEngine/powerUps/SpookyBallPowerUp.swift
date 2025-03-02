struct SpookyBallPowerUp: GamePowerUp {
    func activate(state: GameState) -> GameState {
        SpookyBallGameState(gameState: state)
    }
}
