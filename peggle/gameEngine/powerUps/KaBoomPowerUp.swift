struct KaBoomPowerUp: GamePowerUp {
    func activate(state: GameState) -> GameState {
        KaBoomGameState(gameState: state)
    }
}
