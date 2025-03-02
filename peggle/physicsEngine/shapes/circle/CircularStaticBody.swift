struct CircularStaticBody: CircularCollidable {
    let center: Position
    let radius: Double
    let restitution: Double

    func onCollision(circularCollidable: CircularCollidable, deltaTime: Double) -> CircularStaticBody {
        self
    }

    func onCollision(rectangularCollidable: RectangularCollidable, deltaTime: Double) -> CircularStaticBody {
        self
    }

    func onCollision(triangularCollidable: TriangularCollidable, deltaTime: Double) -> CircularStaticBody {
        self
    }
}

extension CircularStaticBody: CollisionVisitor {
    func visitCollision<T: Collidable>(with collidable: T, deltaTime: Double) -> T {
        collidable.onCollision(circularCollidable: self, deltaTime: deltaTime)
    }
}
