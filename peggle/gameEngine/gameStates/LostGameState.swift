import Foundation

struct LostGameState: GameState {

    let activeBall: Ball?
    let pegs: [UUID: PegModelable]
    let collidedPegs: [UUID: PegModelable]
    let explodedPegs: [UUID: PegModelable]
    let bucket: Bucket
    let boundary: Boundary
    let triangularBlocks: [TriangularBlockModel]
    let remainingBalls: Int

    init(
        activeBall: Ball?,
        pegs: [UUID: PegModelable],
        collidedPegs: [UUID: PegModelable],
        explodedPegs: [UUID: PegModelable],
        bucket: Bucket,
        boundary: Boundary,
        triangularBlocks: [TriangularBlockModel],
        remainingBalls: Int
    ) {
        self.activeBall = activeBall
        self.pegs = pegs
        self.collidedPegs = collidedPegs
        self.explodedPegs = explodedPegs
        self.bucket = bucket
        self.boundary = boundary
        self.triangularBlocks = triangularBlocks
        self.remainingBalls = remainingBalls
    }

    init(state: GameState) {
        activeBall = state.activeBall
        pegs = state.pegs
        collidedPegs = state.collidedPegs
        explodedPegs = state.explodedPegs
        bucket = state.bucket
        boundary = state.boundary
        triangularBlocks = state.triangularBlocks
        remainingBalls = state.remainingBalls
    }

    func next(action: GameAction) -> GameState {
        action.execute(state: self)
    }

    func isOngoing() -> Bool {
        false
    }

    func isWon() -> Bool {
        false
    }

    func setBoundary(_ boundary: Boundary) -> LostGameState {
        LostGameState(
            activeBall: activeBall,
            pegs: pegs,
            collidedPegs: collidedPegs,
            explodedPegs: explodedPegs,
            bucket: bucket,
            boundary: boundary,
            triangularBlocks: triangularBlocks,
            remainingBalls: remainingBalls
        )
    }
}
