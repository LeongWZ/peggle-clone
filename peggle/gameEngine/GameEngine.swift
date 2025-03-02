import Foundation

class GameEngine {
    private static let MaximumDeltaTime: Double = 1.0 / 60
    private static let InitialBoundary = Boundary(width: 0, height: 0)
    private static let EmptyBoard = BoardModel(
        id: UUID(),
        levelId: nil,
        normalPegs: [],
        pointPegs: [],
        powerUpPegs: [],
        triangularBlocks: []
    )

    private var initialGameState: OngoingGameState

    private var gameState: GameState

    init(board: BoardModel, boundary: Boundary) {
        initialGameState = OngoingGameState(board: board, boundary: boundary)
        gameState = initialGameState
    }

    convenience init() {
        self.init(board: GameEngine.EmptyBoard, boundary: GameEngine.InitialBoundary)
    }

    func snapshot() -> GameState {
        gameState
    }

    func launchBall(from source: Position, to target: Position) -> GameState {
        gameState = gameState
            .next(action: LaunchBallAction(source: source, target: target, deltaTime: GameEngine.MaximumDeltaTime))
        return gameState
    }

    func refresh(deltaTime: Double) -> GameState {
        gameState = gameState.next(
            action: RefreshAction(deltaTime: min(deltaTime, GameEngine.MaximumDeltaTime))
        )
        return gameState
    }

    func reset() {
        gameState = initialGameState
    }

    func reset(board: BoardModel, boundary: Boundary? = nil) {
        initialGameState = OngoingGameState(board: board, boundary: boundary ?? gameState.boundary)
        gameState = initialGameState
    }

    func updateBoundary(width: Double, height: Double) {
        let boundary = Boundary(width: width, height: height)
        initialGameState = initialGameState.setBoundary(boundary)
        gameState = gameState.setBoundary(boundary)
    }

    func activatePowerUp(powerUp: GamePowerUp) {
        gameState = gameState.next(action: ActivatePowerUpAction(powerUp: powerUp))
    }
}
