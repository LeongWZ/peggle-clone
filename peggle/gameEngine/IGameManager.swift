import Foundation

protocol IGameManager: IGameLoop {
    var gameEngine: GameEngine { get }

    func reloadBoard()

    func notifyGameStateObservers(_ gameState: GameState)

    func showGameEndAlert(title: String, message: String)

    func setLevel(_ level: LevelModel)

    func setLevel(_ levelId: UUID)
}

extension IGameManager {
    var isGameOngoing: Bool {
        gameEngine.snapshot().isOngoing()
    }

    func refreshGame(deltaTime: Double) {
        let gameState = gameEngine.refresh(deltaTime: deltaTime)

        notifyGameStateObservers(gameState)

        if gameState.isOngoing() {
            return
        }

        stopLoop()

        if gameState.isWon() {
            showGameEndAlert(title: "YOU WIN!", message: "Congratulations! You cleared all the orange pegs.")
            return
        }

        showGameEndAlert(title: "GAME OVER", message: "You ran out of balls!")
    }

    func setGameBoundary(bounds: CGRect) {
        gameEngine.updateBoundary(width: bounds.width, height: bounds.height)
    }

    func resetGame() {
        gameEngine.reset()
        reloadBoard()
    }

    func activatePowerUp(powerUp: GamePowerUp) {
        gameEngine.activatePowerUp(powerUp: powerUp)
    }
}
