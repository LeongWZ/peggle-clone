import Foundation

struct FreeBody {
    let mass: Double
    let position: Position
    let velocity: Velocity

    func setPosition(_ position: Position) -> FreeBody {
        FreeBody(mass: mass, position: position, velocity: velocity)
    }

    func move(deltaTime: Double) -> FreeBody {
        let newPosition = position.update(using: velocity, deltaTime: deltaTime)
        return setPosition(newPosition)
    }

    func applyForces(_ forces: [Force], deltaTime: Double) -> FreeBody {
        guard mass > 0 else {
            return self
        }

        let resultantForce = Force.getResultantForce(forces: forces)
        let acceleration = Acceleration(ax: resultantForce.fx / mass, ay: resultantForce.fy / mass)
        let newVelocity = velocity.update(using: acceleration, deltaTime: deltaTime)
        let newPosition = position.update(using: newVelocity, deltaTime: deltaTime)

        return FreeBody(mass: mass, position: newPosition, velocity: newVelocity)
    }

    func onCollision(at position: Position, deltaTime: Double, restitution: Double) -> FreeBody {
        let collisionForce = getCollisionForce(at: position, deltaTime: deltaTime,
                                               restitution: restitution)
        return applyForces([collisionForce], deltaTime: deltaTime)
    }

    private func getCollisionForce(at collisionPoint: Position, deltaTime: Double,
                                   restitution: Double) -> Force {
        guard deltaTime > 0 else {
            return Force(fx: 0, fy: 0)
        }

        let velocity1 = Velocity(
            vx: collisionPoint.xCartesian - position.xCartesian,
            vy: collisionPoint.yCartesian - position.yCartesian)
            .normalize()
        let velocity2 = velocity

        let dotProduct = velocity1.vx * velocity2.vx + velocity1.vy * velocity2.vy
        let normalVelocity = velocity1.scale(by: dotProduct)

        return Force(fx: normalVelocity.vx, fy: normalVelocity.vy)
            .scale(by: -(1 + restitution) * mass / deltaTime)
    }
}

// MARK: Equatable, Hashable
extension FreeBody: Equatable, Hashable {
}
