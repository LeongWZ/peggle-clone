import Foundation

struct KaBoomGameState: GameState {
    private static let BlastRadius: Double = 150

    private let ongoingGameState: OngoingGameState

    private let physicsEngine = PhysicsEngine()

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

    func isOngoing() -> Bool {
        true
    }

    func isWon() -> Bool {
        false
    }

    func setBoundary(_ boundary: Boundary) -> KaBoomGameState {
        KaBoomGameState(ongoingGameState: ongoingGameState.setBoundary(boundary))
    }

    func launchBall(from start: Position, to target: Position, deltaTime: Double) -> KaBoomGameState {
        let newOngoingGameState = ongoingGameState.launchBall(from: start, to: target, deltaTime: deltaTime)
        return KaBoomGameState(ongoingGameState: newOngoingGameState)
    }

    func refresh(deltaTime: Double) -> GameState {
        let refreshedState: GameState = ongoingGameState.refresh(deltaTime: deltaTime)

        if !refreshedState.isOngoing() {
            return refreshedState
        }

        let newOngoingGameState = OngoingGameStateBuilder(state: ongoingGameState)
            .withActiveBall(refreshedState.activeBall)
            .withBoard(board.removePegs { peg in !refreshedState.pegs.keys.contains(peg.id) })
            .withCollidedPegs(refreshedState.collidedPegs)
            .withExplodedPegs(refreshedState.explodedPegs)
            .withBucket(refreshedState.bucket)
            .withRemainingBalls(refreshedState.remainingBalls)
            .build()

        let newBallBeforeCollisionResolution: Ball? = handleMove(ball: activeBall, deltaTime: deltaTime)

        return KaBoomGameState(ongoingGameState: newOngoingGameState)
            .handleExplosions(deltaTime: deltaTime)
            .checkForPowerUp(ball: newBallBeforeCollisionResolution)
    }

    private func checkForPowerUp(ball: Ball?) -> KaBoomGameState {
        if shouldActivateKaBoom(ball: ball) {
            return onKaBoom()
        }

        return self
    }

    private func onKaBoom() -> KaBoomGameState {
        guard let ball = self.activeBall else {
            return self
        }

        let explodedPegsToAdd = getExplodedPegsOnExplosion(explosionPoints: [ball.center])
        let newExplodedPegs = explodedPegs.merging(explodedPegsToAdd, uniquingKeysWith: { current, _ in current })

        let newOngoingGameState = OngoingGameStateBuilder(state: ongoingGameState)
            .withExplodedPegs(newExplodedPegs)
            .build()

        return KaBoomGameState(ongoingGameState: newOngoingGameState)
    }

    private func handleExplosions(deltaTime: Double) -> KaBoomGameState {
        let explosionPoints = explodedPegs.values.map { explodedPeg in explodedPeg.center }
        let pegsToRemove = explodedPegs.merging(
            getRemovedPegsOnExplosion(explosionPoints: explosionPoints),
            uniquingKeysWith: { current, _ in current }
        )
        let newExplodedPegs = getExplodedPegsOnExplosion(explosionPoints: explosionPoints)
        let newBall = handleExplosions(ball: activeBall, explosionPoints: explosionPoints, deltaTime: deltaTime)

        let newOngoingGameState = OngoingGameStateBuilder(state: ongoingGameState)
            .withBoard(board.removePegs { peg in pegsToRemove.keys.contains(peg.id) })
            .withExplodedPegs(newExplodedPegs)
            .withActiveBall(newBall)
            .build()

        return KaBoomGameState(ongoingGameState: newOngoingGameState)
    }

    private func handleMove(ball: Ball?, deltaTime: Double) -> Ball? {
        guard let ball = ball else {
            return nil
        }

        return ball.setCircularBody(
            physicsEngine.move(movable: ball.circularBody, deltaTime: deltaTime)
        )
    }

    private func getRemovedPegsOnExplosion(explosionPoints: [Position]) -> [UUID: PegModelable] {
        let pegsToRemove = pegs.values
            .filter { peg in
                explosionPoints.contains(where: { explosionPoint in
                    explosionPoint.getDistance(to: peg.center) <= KaBoomGameState.BlastRadius
                })
            }
            .filter { peg in board.powerUpPegs.allSatisfy { powerUpPeg in powerUpPeg.id != peg.id } }

        return Dictionary(
            pegsToRemove.map { peg in (peg.id, peg) },
            uniquingKeysWith: { current, _ in current }
        )
    }

    private func getExplodedPegsOnExplosion(explosionPoints: [Position]) -> [UUID: PegModelable] {
        let pegsToExplode = board.powerUpPegs
            .filter { peg in
                explosionPoints.contains(where: { explosionPoint in
                    explosionPoint.getDistance(to: peg.center) <= KaBoomGameState.BlastRadius
                })
            }
            .filter { peg in !explodedPegs.keys.contains(peg.id) }

        return Dictionary(
            pegsToExplode.map { peg in (peg.id, peg) },
            uniquingKeysWith: { current, _ in current }
        )
    }

    private func shouldActivateKaBoom(ball: Ball?) -> Bool {
        guard let ball = ball else {
            return false
        }

        let powerUpPegBodies = board.powerUpPegs.map { peg in peg.toCircularStaticBody() }
        let ballBody = ball.circularBody

        for body in powerUpPegBodies where body.willCollide(with: ballBody) {
            return true
        }

        return false
    }

    private func handleExplosions(ball: Ball?, explosionPoints: [Position], deltaTime: Double) -> Ball? {
        guard let ball = ball else {
            return nil
        }

        let newCircularBody = physicsEngine.handleExplosions(
            for: ball.circularBody,
            explosionPoints: explosionPoints,
            deltaTime: deltaTime
        )

        return ball.setCircularBody(newCircularBody)
    }
}
