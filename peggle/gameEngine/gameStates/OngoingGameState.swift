import Foundation

struct OngoingGameState: GameState {
    private static let LaunchBallForceScale: Double = 3_000
    private static let MaxLaunchBallForceMagnitude: Double = 1_000_000
    private static let RemainingBallsAtStart: Int = 10

    // hide bucket
    private static let InitialBucketPosition = Position(xCartesian: -Bucket.Width / 2, yCartesian: 0)

    let activeBall: Ball?
    let pegs: [UUID: PegModelable]
    let collidedPegs: [UUID: PegModelable]
    let explodedPegs: [UUID: PegModelable]
    let bucket: Bucket
    let boundary: Boundary
    let remainingBalls: Int
    let board: BoardModel

    var triangularBlocks: [TriangularBlockModel] {
        board.triangularBlocks
    }

    private let physicsEngine = PhysicsEngine()

    init(board: BoardModel, boundary: Boundary) {
        activeBall = nil
        self.board = board
        collidedPegs = [:]
        explodedPegs = [:]
        bucket = Bucket(center: OngoingGameState.InitialBucketPosition)
        self.boundary = boundary
        remainingBalls = OngoingGameState.RemainingBallsAtStart

        pegs = Dictionary(
            board.allPegs.map { peg in (peg.id, peg) },
            uniquingKeysWith: { current, _ in current }
        )

    }

    init(activeBall: Ball?, board: BoardModel, collidedPegs: [UUID: PegModelable], explodedPegs: [UUID: PegModelable],
         bucket: Bucket, boundary: Boundary, remainingBalls: Int) {
        self.activeBall = activeBall
        self.board = board
        self.collidedPegs = collidedPegs
        self.explodedPegs = explodedPegs
        self.bucket = bucket
        self.boundary = boundary
        self.remainingBalls = remainingBalls

        pegs = Dictionary(
            board.allPegs.map { peg in (peg.id, peg) },
            uniquingKeysWith: { current, _ in current }
        )
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

    func setBoundary(_ boundary: Boundary) -> OngoingGameState {
        let newBucketPosition = Position(xCartesian: bucket.center.xCartesian,
                                         yCartesian: boundary.height - bucket.height / 2)
        let newBucket = bucket.setPosition(newBucketPosition)

        return OngoingGameStateBuilder(state: self)
            .withBoundary(boundary)
            .withBucket(newBucket)
            .build()
    }

    func launchBall(from start: Position, to target: Position, deltaTime: Double) -> OngoingGameState {
        if isBallInPlay() || remainingBalls <= 0 {
            return self
        }

        let ball = Ball(initialPosition: start)
        let ballAfterLaunch = ball.setCircularBody(
            physicsEngine.exertForces(
                on: ball.circularBody,
                forces: [calculateLaunchForce(from: start, to: target)],
                deltaTime: deltaTime
            )
        )

        return OngoingGameStateBuilder(state: self)
            .withActiveBall(ballAfterLaunch)
            .withRemainingBalls(remainingBalls - 1)
            .build()
    }

    func refresh(deltaTime: Double) -> GameState {
        let newBall: Ball? = handleMove(ball: activeBall, deltaTime: deltaTime)
        let newBucket = handleCollision(
            bucket: handleMove(bucket: bucket, deltaTime: deltaTime),
            deltaTime: deltaTime
        )

        guard isBallInPlay() else {
            return OngoingGameStateBuilder(state: self)
                .withBucket(newBucket.observe(ball: nil))
                .withActiveBall(nil)
                .build()
                .removeCollidedPegs()
                .resolveGame()
        }

        return OngoingGameStateBuilder(state: self)
            .withActiveBall(handleCollision(ball: newBall, deltaTime: deltaTime))
            .withCollidedPegs(getCollidedPegs(ball: newBall))
            .withBucket(newBucket.observe(ball: newBall))
            .build()
            .resolveStuckBall()
    }

    private func resolveStuckBall() -> OngoingGameState {
        guard let ball = self.activeBall, ball.isStuck() else {
            return self
        }

        return removeCollidedPegs()
    }

    private func removeCollidedPegs() -> OngoingGameState {
        OngoingGameStateBuilder(state: self)
            .withBoard(board.removePegs { peg in collidedPegs.keys.contains(peg.id) })
            .withCollidedPegs([:])
            .build()
    }

    private func getCollidedPegs(ball: Ball?) -> [UUID: PegModelable] {
        let collidedPegsToAdd: [UUID: PegModelable] = pegs.filter { _, peg in
            let pegCircularBody = peg.toCircularStaticBody()
            let ballCircularBody = ball?.circularBody
            return ballCircularBody?.willCollide(with: pegCircularBody) ?? false
        }

        let newCollidedPegs = collidedPegs.merging(collidedPegsToAdd, uniquingKeysWith: { current, _ in current })

        return newCollidedPegs
    }

    private func calculateLaunchForce(from start: Position, to target: Position) -> Force {
        let launchForce = Force(fx: target.xCartesian - start.xCartesian, fy: target.yCartesian - start.yCartesian)
            .scale(by: OngoingGameState.LaunchBallForceScale)

        if launchForce.magnitude > OngoingGameState.MaxLaunchBallForceMagnitude {
            return launchForce.normalize().scale(by: OngoingGameState.MaxLaunchBallForceMagnitude)
        }

        return launchForce
    }

    private func handleMove(ball: Ball?, deltaTime: Double) -> Ball? {
        guard let ball = ball else {
            return nil
        }

        return ball.setCircularBody(
            physicsEngine.move(movable: ball.circularBody, deltaTime: deltaTime)
        )
    }

    private func handleMove(bucket: Bucket, deltaTime: Double) -> Bucket {
        let newRectangularFreeBody = physicsEngine.move(
            movable: bucket.rectangularFreeBody, deltaTime: deltaTime, isIsolated: true)

        return bucket.setRectangularFreeBody(newRectangularFreeBody)
    }

    private func handleCollision(ball: Ball?, deltaTime: Double) -> Ball? {
        guard let ball = ball else {
            return nil
        }

        let ballCollisionVisitors: [CollisionVisitor] = pegs.values.map { peg in peg.toCircularStaticBody() }
            + triangularBlocks.map { block in block.toTriangularStaticBody() }
            + boundary.walls.map { wall in wall.rectangularStaticBody }
            + [bucket.rectangularFreeBody]

        let newCircularBody = physicsEngine.handleCollisions(
            collidable: ball.circularBody,
            collisionVisitors: ballCollisionVisitors,
            deltaTime: deltaTime
        )

        return ball.setCircularBody(newCircularBody)
    }

    private func handleCollision(bucket: Bucket, deltaTime: Double) -> Bucket {
        let newRectangularFreeBody = physicsEngine.handleCollisions(
                collidable: bucket.rectangularFreeBody,
                collisionVisitors: boundary.walls.map { wall in wall.rectangularStaticBody },
                deltaTime: deltaTime
        )

        return bucket.setRectangularFreeBody(newRectangularFreeBody)
    }

    private func resolveGame() -> GameState {
        if activeBall == nil && board.pointPegs.isEmpty {
            return WonGameState(state: self)
        }

        if activeBall == nil && remainingBalls <= 0 {
            return LostGameState(state: self)
        }

        return self
    }
}
