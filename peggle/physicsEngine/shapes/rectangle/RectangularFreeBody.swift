struct RectangularFreeBody: RectangularCollidable {
    let freeBody: FreeBody
    let width: Double
    let height: Double
    let restitution: Double

    var center: Position {
        freeBody.position
    }

    init(center: Position, mass: Double, width: Double, height: Double, restitution: Double) {
        freeBody = FreeBody(mass: mass, position: center, velocity: Velocity(vx: 0, vy: 0))
        self.width = width
        self.height = height
        self.restitution = restitution
    }

    init(center: Position, mass: Double, width: Double, height: Double, restitution: Double, velocity: Velocity) {
        freeBody = FreeBody(mass: mass, position: center, velocity: velocity)
        self.width = width
        self.height = height
        self.restitution = restitution
    }

    init(freeBody: FreeBody, width: Double, height: Double, restitution: Double) {
        self.freeBody = freeBody
        self.width = width
        self.height = height
        self.restitution = restitution
    }

    func setFreeBody(_ freeBody: FreeBody) -> RectangularFreeBody {
        RectangularFreeBody(freeBody: freeBody, width: width, height: height, restitution: restitution)
    }

    func setPosition(_ position: Position) -> RectangularFreeBody {
        setFreeBody(freeBody.setPosition(position))
    }

    /// Not yet implemented
    func onCollision(circularCollidable: CircularCollidable, deltaTime: Double) -> RectangularFreeBody {
        self
    }

    /// Not yet implemented
    func onCollision(triangularCollidable: TriangularCollidable, deltaTime: Double) -> RectangularFreeBody {
        self
    }

    func onCollision(rectangularCollidable: RectangularCollidable, deltaTime: Double) -> RectangularFreeBody {
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
            xCartesian: min(center.xCartesian, rectangularCollidable.leftEdge - width / 2),
            yCartesian: center.yCartesian
        )
    }

    private func getSafePositionFromRightEdge(_ rectangularCollidable: RectangularCollidable) -> Position {
        Position(
            xCartesian: max(center.xCartesian, rectangularCollidable.rightEdge + width / 2),
            yCartesian: center.yCartesian
        )
    }

    private func getSafePositionFromBottomEdge(_ rectangularCollidable: RectangularCollidable) -> Position {
        Position(
            xCartesian: center.xCartesian,
            yCartesian: max(center.yCartesian, rectangularCollidable.bottomEdge + height / 2)
        )
    }

    private func getSafePositionFromTopEdge(_ rectangularCollidable: RectangularCollidable) -> Position {
        Position(
            xCartesian: center.xCartesian,
            yCartesian: min(center.yCartesian, rectangularCollidable.topEdge - height / 2)
        )
    }

}

extension RectangularFreeBody: CollisionVisitor {
    func visitCollision<T: Collidable>(with collidable: T, deltaTime: Double) -> T {
        collidable.onCollision(rectangularCollidable: self, deltaTime: deltaTime)
    }
}

extension RectangularFreeBody: Movable {
    var mass: Double {
        freeBody.mass
    }

    func move(externalForces: [Force], deltaTime: Double) -> Self {
        let newFreeBody = freeBody.applyForces(externalForces, deltaTime: deltaTime)
        return setFreeBody(newFreeBody)
    }
}
