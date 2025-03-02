protocol GameStateObserver: AnyObject {

    /// - Returns: `true` if still observing, otherwise `false`
    func observe(_ gameState: GameState) -> Bool
}
