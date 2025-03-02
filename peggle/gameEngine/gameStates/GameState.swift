import Foundation

protocol GameState {
    var activeBall: Ball? { get }
    var pegs: [UUID: PegModelable] { get }
    var collidedPegs: [UUID: PegModelable] { get }
    var explodedPegs: [UUID: PegModelable] { get }
    var bucket: Bucket { get }
    var boundary: Boundary { get }
    var triangularBlocks: [TriangularBlockModel] { get }
    var remainingBalls: Int { get }

    func next(action: GameAction) -> GameState

    func setBoundary(_ boundary: Boundary) -> Self

    func isOngoing() -> Bool

    func isWon() -> Bool
}

extension GameState {
    func isBallInPlay() -> Bool {
        guard isOngoing(), let ball = self.activeBall else {
            return false
        }

        let isOutOfBounds = boundary.isBallOutOfBounds(ball)
        let isCaughtByBucket = bucket.hasBall

        return !(isOutOfBounds || isCaughtByBucket)
    }
}
