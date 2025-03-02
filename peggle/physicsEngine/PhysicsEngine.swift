import Foundation

struct PhysicsEngine {
    private static let GravitationalAcceleration: Double = 754
    private static let ExplosionForceScale: Double = 10_000_000

    func handleCollisions<T: Collidable>(collidable: T, collisionVisitors: [CollisionVisitor], deltaTime: Double) -> T {
        collisionVisitors.reduce(collidable, { collidable, collisionVisitor in
            collisionVisitor.visitCollision(with: collidable, deltaTime: deltaTime)
        })
    }

    func move<T: Movable>(movable: T, deltaTime: Double, isIsolated: Bool = false) -> T {
        if isIsolated {
            return movable.move(externalForces: [], deltaTime: deltaTime)
        }

        let weight = movable.getWeight(g: PhysicsEngine.GravitationalAcceleration)
        return movable.move(externalForces: [weight], deltaTime: deltaTime)
    }

    func exertForces<T: Movable>(on movable: T, forces: [Force], deltaTime: Double) -> T {
        movable.move(externalForces: forces, deltaTime: deltaTime)
    }

    func handleExplosions<T: Movable>(for movable: T, explosionPoints: [Position], deltaTime: Double) -> T {
        let explosionForces = explosionPoints.map { explosionPoint in
            let distanceToMovable = movable.center.getDistance(to: explosionPoint)

            guard distanceToMovable > 0 else {
                return Force(fx: 0, fy: 0)
            }

            return Force(
                fx: movable.center.xCartesian - explosionPoint.xCartesian,
                fy: movable.center.yCartesian - explosionPoint.yCartesian
            ).scale(by: PhysicsEngine.ExplosionForceScale / pow(distanceToMovable, 2))
        }

        return exertForces(on: movable, forces: explosionForces, deltaTime: deltaTime)
    }
}
