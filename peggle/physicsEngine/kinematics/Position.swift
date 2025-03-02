import Foundation

struct Position {
    let xCartesian: Double
    let yCartesian: Double

    func update(using velocity: Velocity, deltaTime: Double) -> Position {
        Position(
            xCartesian: xCartesian + velocity.vx * deltaTime,
            yCartesian: yCartesian + velocity.vy * deltaTime
        )
    }

    func getDistance(to other: Position) -> Double {
        let deltaX = xCartesian - other.xCartesian
        let deltaY = yCartesian - other.yCartesian
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }

    func toCGPoint() -> CGPoint {
        CGPoint(x: xCartesian, y: yCartesian)
    }
}

// MARK: Hashable, Equatable
extension Position: Hashable, Equatable {
}
