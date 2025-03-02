import Foundation

class OngoingGameStateBuilder {
    private var activeBall: Ball?
    private var board: BoardModel
    private var collidedPegs: [UUID: PegModelable]
    private var explodedPegs: [UUID: PegModelable]
    private var bucket: Bucket
    private var boundary: Boundary
    private var remainingBalls: Int

    init(
        activeBall: Ball?,
        board: BoardModel,
        collidedPegs: [UUID: PegModelable],
        explodedPegs: [UUID: PegModelable],
        bucket: Bucket,
        boundary: Boundary,
        remainingBalls: Int
    ) {
        self.activeBall = activeBall
        self.board = board
        self.collidedPegs = collidedPegs
        self.explodedPegs = explodedPegs
        self.bucket = bucket
        self.boundary = boundary
        self.remainingBalls = remainingBalls
    }

    init(state: OngoingGameState) {
        activeBall = state.activeBall
        board = state.board
        collidedPegs = state.collidedPegs
        explodedPegs = state.explodedPegs
        bucket = state.bucket
        boundary = state.boundary
        remainingBalls = state.remainingBalls
    }

    func withActiveBall(_ activeBall: Ball?) -> OngoingGameStateBuilder {
        self.activeBall = activeBall
        return self
    }

    func withBoard(_ board: BoardModel) -> OngoingGameStateBuilder {
        self.board = board
        return self
    }

    func withCollidedPegs(_ collidedPegs: [UUID: PegModelable]) -> OngoingGameStateBuilder {
        self.collidedPegs = collidedPegs
        return self
    }

    func withExplodedPegs(_ explodedPegs: [UUID: PegModelable]) -> OngoingGameStateBuilder {
        self.explodedPegs = explodedPegs
        return self
    }

    func withBucket(_ bucket: Bucket) -> OngoingGameStateBuilder {
        self.bucket = bucket
        return self
    }

    func withBoundary(_ boundary: Boundary) -> OngoingGameStateBuilder {
        self.boundary = boundary
        return self
    }

    func withRemainingBalls(_ remainingBalls: Int) -> OngoingGameStateBuilder {
        assert(remainingBalls >= 0, "remainingBalls should be a non-negative integer")
        self.remainingBalls = remainingBalls
        return self
    }

    func build() -> OngoingGameState {
        OngoingGameState(
            activeBall: activeBall,
            board: board,
            collidedPegs: collidedPegs,
            explodedPegs: explodedPegs,
            bucket: bucket,
            boundary: boundary,
            remainingBalls: remainingBalls
        )
    }
}
