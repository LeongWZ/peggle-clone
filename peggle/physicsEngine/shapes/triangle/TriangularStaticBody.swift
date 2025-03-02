struct TriangularStaticBody: TriangularCollidable {
    let firstPoint: Position
    let secondPoint: Position
    let thirdPoint: Position
    let restitution: Double

    func onCollision(circularCollidable: CircularCollidable, deltaTime: Double) -> TriangularStaticBody {
        self
    }

    func onCollision(rectangularCollidable: RectangularCollidable, deltaTime: Double) -> TriangularStaticBody {
        self
    }

    func onCollision(triangularCollidable: TriangularCollidable, deltaTime: Double) -> TriangularStaticBody {
        self
    }
}

extension TriangularStaticBody: CollisionVisitor {
    func visitCollision<T: Collidable>(with collidable: T, deltaTime: Double) -> T {
        collidable.onCollision(triangularCollidable: self, deltaTime: deltaTime)
    }
}
