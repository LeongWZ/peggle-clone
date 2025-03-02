import Foundation

struct Force {
    let fx: Double
    let fy: Double

    var magnitude: Double {
        sqrt(fx * fx + fy * fy)
    }

    func scale(by scalar: Double) -> Force {
        Force(fx: fx * scalar, fy: fy * scalar)
    }

    func normalize() -> Force {
        guard magnitude > 0 else {
            return Force(fx: 0, fy: 0)
        }

        return scale(by: 1.0 / magnitude)
    }

    static func getResultantForce(forces: [Force]) -> Force {
        var fx: Double = 0
        var fy: Double = 0

        for force in forces {
            fx += force.fx
            fy += force.fy
        }

        return Force(fx: fx, fy: fy)
    }
}

// MARK: Equatable, Hashable
extension Force: Equatable, Hashable {
}
