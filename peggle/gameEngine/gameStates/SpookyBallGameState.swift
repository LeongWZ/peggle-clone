import Foundation

struct SpookyBallGameState: GameState {
    private let ongoingGameState: OngoingGameState

    private var board: BoardModel {
        ongoingGameState.board
    }

    var activeBall: Ball? {
        ongoingGameState.activeBall
    }

    var pegs: [UUID: PegModelable] {
        ongoingGameState.pegs
    }

    var collidedPegs: [UUID: PegModelable] {
        ongoingGameState.collidedPegs
    }

    var explodedPegs: [UUID: PegModelable] {
        ongoingGameState.explodedPegs
    }

    var bucket: Bucket {
        ongoingGameState.bucket
    }

    var boundary: Boundary {
        ongoingGameState.boundary
    }

    var triangularBlocks: [TriangularBlockModel] {
        ongoingGameState.triangularBlocks
    }

    var remainingBalls: Int {
        ongoingGameState.remainingBalls
    }

    init(gameState: GameState) {
        let board = gameState.pegs.values.reduce(
            BoardModel(
                id: UUID(),
                levelId: nil,
                normalPegs: [],
                pointPegs: [],
                powerUpPegs: [],
                triangularBlocks: gameState.triangularBlocks
            ),
            { result, peg in peg.addToBoard(board: result) }
        )

        ongoingGameState = OngoingGameState(
            activeBall: gameState.activeBall,
            board: board,
            collidedPegs: gameState.collidedPegs,
            explodedPegs: gameState.explodedPegs,
            bucket: gameState.bucket,
            boundary: gameState.boundary,
            remainingBalls: gameState.remainingBalls
        )
    }

    init(board: BoardModel, boundary: Boundary) {
        ongoingGameState = OngoingGameState(board: board, boundary: boundary)
    }

    /// Private initializer to speed up computation because`init(gameState)` runs in O(n^2) time
    private init(ongoingGameState: OngoingGameState) {
        self.ongoingGameState = ongoingGameState
    }

    func next(action: GameAction) -> GameState {
        action.execute(state: self)
    }

    func setBoundary(_ boundary: Boundary) -> SpookyBallGameState {
        let newOngoingGameState = ongoingGameState.setBoundary(boundary)
        return SpookyBallGameState(ongoingGameState: newOngoingGameState)
    }

    func isOngoing() -> Bool {
        true
    }

    func isWon() -> Bool {
        false
    }

    func launchBall(from start: Position, to target: Position, deltaTime: Double) -> SpookyBallGameState {
        let newOngoingGameState = ongoingGameState.launchBall(from: start, to: target, deltaTime: deltaTime)

        return SpookyBallGameState(ongoingGameState: newOngoingGameState)
    }

    func refresh(deltaTime: Double) -> GameState {
        let refreshedState = ongoingGameState.refresh(deltaTime: deltaTime)

        if !refreshedState.isOngoing() {
            return refreshedState
        }

        let newBall = shouldActivateSpookyBall(refreshedState)
            ? createSpookyBall(refreshedState)
            : refreshedState.activeBall

        let newOngoingGameState = OngoingGameStateBuilder(state: ongoingGameState)
            .withActiveBall(newBall)
            .withBoard(board.removePegs { peg in !refreshedState.pegs.keys.contains(peg.id) })
            .withCollidedPegs(refreshedState.collidedPegs)
            .withExplodedPegs(refreshedState.explodedPegs)
            .withBucket(refreshedState.bucket)
            .withRemainingBalls(refreshedState.remainingBalls)
            .build()

        return SpookyBallGameState(ongoingGameState: newOngoingGameState)
    }

    private func createSpookyBall(_ refreshedState: GameState) -> Ball? {
        guard let ball = refreshedState.activeBall else {
            return nil
        }

        return ball.setCenter(
            Position(xCartesian: ball.center.xCartesian, yCartesian: ball.radius)
        )
    }

    private func shouldActivateSpookyBall(_ refreshedState: GameState) -> Bool {
        guard let ball = refreshedState.activeBall else {
            return false
        }

        let isBallOutOfBottomBound = ball.center.yCartesian >= boundary.height + ball.radius

        let hasBallCollidedWithPowerUpPeg = board.powerUpPegs.contains(
            where: { peg in refreshedState.collidedPegs.keys.contains(peg.id) }
        )

        return isBallOutOfBottomBound && hasBallCollidedWithPowerUpPeg
    }

}
