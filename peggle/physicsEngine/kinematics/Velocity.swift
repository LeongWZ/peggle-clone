import Foundation

struct Velocity {
    let vx: Double
    let vy: Double

    func update(using acceleration: Acceleration, deltaTime: Double) -> Velocity {
        Velocity(vx: vx + acceleration.ax * deltaTime, vy: vy + acceleration.ay * deltaTime)
    }

    var magnitude: Double {
        sqrt(vx * vx + vy * vy)
    }

    func normalize() -> Velocity {
        let magnitude = self.magnitude

        guard magnitude > 0 else {
            return Velocity(vx: 0, vy: 0)
        }

        return Velocity(vx: vx / magnitude, vy: vy / magnitude)
    }

    func scale(by scale: Double) -> Velocity {
        Velocity(vx: vx * scale, vy: vy * scale)
    }

    func negate() -> Velocity {
        scale(by: -1)
    }
}

// MARK: Equatable, Hashable
extension Velocity: Equatable, Hashable {
}
