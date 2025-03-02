import Foundation

struct CircularFreeBody {
    private static let MaxCollisionIterations: Int = 100
    let freeBody: FreeBody
    let radius: Double
    let restitution: Double

    var center: Position {
        freeBody.position
    }

    init(center: Position, mass: Double, radius: Double, restitution: Double) {
        freeBody = FreeBody(mass: mass, position: center, velocity: Velocity(vx: 0, vy: 0))
        self.radius = radius
        self.restitution = restitution
    }

    init(freeBody: FreeBody, radius: Double, restitution: Double) {
        self.freeBody = freeBody
        self.radius = radius
        self.restitution = restitution
    }

    func setFreeBody(_ freeBody: FreeBody) -> Self {
        CircularFreeBody(freeBody: freeBody, radius: radius, restitution: restitution)
    }

    func setPosition(_ position: Position) -> Self {
        setFreeBody(freeBody.setPosition(position))
    }
 }

extension CircularFreeBody: CircularCollidable {
    func onCollision(rectangularCollidable: RectangularCollidable, deltaTime: Double) -> CircularFreeBody {
        guard willCollide(with: rectangularCollidable) else {
            return self
        }

        let isHorizontallyWithinRectangle = leftEdge >= rectangularCollidable.leftEdge
            && rightEdge <= rectangularCollidable.rightEdge

        let collisionPoint = isHorizontallyWithinRectangle
            ? Position(xCartesian: center.xCartesian, yCartesian: rectangularCollidable.center.yCartesian)
            : Position(xCartesian: rectangularCollidable.center.xCartesian, yCartesian: center.yCartesian)

        let newFreeBody = freeBody
            .setPosition(getSafePosition(from: rectangularCollidable))
            .onCollision(at: collisionPoint, deltaTime: deltaTime, restitution: restitution)

        return setFreeBody(newFreeBody)
    }

    func onCollision(circularCollidable: CircularCollidable, deltaTime: Double) -> Self {
        guard willCollide(with: circularCollidable) else {
            return self
        }

        let newFreeBody = freeBody
            .setPosition(getSafePosition(from: circularCollidable))
            .onCollision(
                at: circularCollidable.center,
                deltaTime: deltaTime,
                restitution: circularCollidable.restitution
            )

        return CircularFreeBody(freeBody: newFreeBody, radius: radius, restitution: restitution)
    }

    func onCollision(triangularCollidable: TriangularCollidable, deltaTime: Double) -> CircularFreeBody {
        guard let collisionPoint = getCollisionPoint(with: triangularCollidable) else {
            return self
        }

        let newFreeBody = freeBody
            .setPosition(getSafePosition(from: triangularCollidable, deltaTime: deltaTime))
            .onCollision(
                at: collisionPoint,
                deltaTime: deltaTime,
                restitution: triangularCollidable.restitution
            )

        return CircularFreeBody(freeBody: newFreeBody, radius: radius, restitution: restitution)
    }

    private func getSafePosition(from circularCollidable: CircularCollidable) -> Position {
        guard willCollide(with: circularCollidable) else {
            return center
        }

        let circularCollidableCenter = circularCollidable.center

        let angleToSelf = atan2(center.yCartesian - circularCollidableCenter.yCartesian,
                                center.xCartesian - circularCollidableCenter.xCartesian)

        return generatePointAlongCircle(center: circularCollidableCenter,
                                        radius: circularCollidable.radius + radius, angleRadians: angleToSelf)
    }

    private func generatePointAlongCircle(center: Position, radius: Double, angleRadians: Double) -> Position {
        let pointX = center.xCartesian + radius * cos(angleRadians)
        let pointY = center.yCartesian + radius * sin(angleRadians)
        return Position(xCartesian: pointX, yCartesian: pointY)
    }

    private func getSafePosition(from rectangularCollidable: RectangularCollidable) -> Position {
        guard willCollide(with: rectangularCollidable) else {
            return center
        }

        let distanceToLeftEdge = abs(center.xCartesian - rectangularCollidable.leftEdge)
        let distanceToRightEdge = abs(center.xCartesian - rectangularCollidable.rightEdge)
        let distanceToTopEdge = abs(center.yCartesian - rectangularCollidable.topEdge)
        let distanceToBottomEdge = abs(center.yCartesian - rectangularCollidable.bottomEdge)

        let smallestDistance = min(distanceToLeftEdge, distanceToRightEdge,
                                   distanceToTopEdge, distanceToBottomEdge)

        if smallestDistance == distanceToRightEdge {
            // closer to right side of rectangle
            return getSafePositionFromRightEdge(rectangularCollidable)
        }

        if smallestDistance == distanceToLeftEdge {
            // closer to left side of rectangle
            return getSafePositionFromLeftEdge(rectangularCollidable)
        }

        if smallestDistance == distanceToBottomEdge {
            // closer to bottom side of rectangle
            return getSafePositionFromBottomEdge(rectangularCollidable)
        }

        // closer to top side of rectangle
        return getSafePositionFromTopEdge(rectangularCollidable)
    }

    private func getSafePositionFromLeftEdge(_ rectangularCollidable: RectangularCollidable) -> Position {
        Position(
            xCartesian: min(center.xCartesian, rectangularCollidable.leftEdge - radius),
            yCartesian: center.yCartesian
        )
    }

    private func getSafePositionFromRightEdge(_ rectangularCollidable: RectangularCollidable) -> Position {
        Position(
            xCartesian: max(center.xCartesian, rectangularCollidable.rightEdge + radius),
            yCartesian: center.yCartesian
        )
    }

    private func getSafePositionFromBottomEdge(_ rectangularCollidable: RectangularCollidable) -> Position {
        Position(
            xCartesian: center.xCartesian,
            yCartesian: max(center.yCartesian, rectangularCollidable.bottomEdge + radius)
        )
    }

    private func getSafePositionFromTopEdge(_ rectangularCollidable: RectangularCollidable) -> Position {
        Position(
            xCartesian: center.xCartesian,
            yCartesian: min(center.yCartesian, rectangularCollidable.topEdge - radius)
        )
    }

    private func getSafePosition(from triangularCollidable: TriangularCollidable, deltaTime: Double) -> Position {
        assert(CircularFreeBody.MaxCollisionIterations > 0, "MaxCollisionIterations must be positive")

        // rewind the clock and get previous states of freeBody
        let previousFreeBodies = sequence(first: freeBody) { freeBody in
            freeBody.move(deltaTime: -1 * deltaTime / Double(CircularFreeBody.MaxCollisionIterations))
        }
            .prefix(CircularFreeBody.MaxCollisionIterations)

        if let resolvedFreeBody = previousFreeBodies.first(where: {
            !setFreeBody($0).willCollide(with: triangularCollidable)
        }) {
            return resolvedFreeBody.position
        }

        return Array(previousFreeBodies).last?.position ?? center
    }
}

extension CircularFreeBody: CollisionVisitor {
    func visitCollision<T: Collidable>(with collidable: T, deltaTime: Double) -> T {
        collidable.onCollision(circularCollidable: self, deltaTime: deltaTime)
    }
}

extension CircularFreeBody: Movable {
    var mass: Double {
        freeBody.mass
    }

    func move(externalForces: [Force], deltaTime: Double) -> Self {
        let newFreeBody = freeBody.applyForces(externalForces, deltaTime: deltaTime)
        return setFreeBody(newFreeBody)
    }
}

// MARK: Equatable, Hashable
extension CircularFreeBody: Equatable, Hashable {
}
