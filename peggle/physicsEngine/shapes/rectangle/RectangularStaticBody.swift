struct RectangularStaticBody: RectangularCollidable {
    let center: Position
    let width: Double
    let height: Double
    let restitution: Double

    func onCollision(circularCollidable: CircularCollidable, deltaTime: Double) -> RectangularStaticBody {
        self
    }

    func onCollision(rectangularCollidable: RectangularCollidable, deltaTime: Double) -> RectangularStaticBody {
        self
    }

    func onCollision(triangularCollidable: TriangularCollidable, deltaTime: Double) -> RectangularStaticBody {
        self
    }
}

extension RectangularStaticBody: CollisionVisitor {
    func visitCollision<T: Collidable>(with collidable: T, deltaTime: Double) -> T {
        collidable.onCollision(rectangularCollidable: self, deltaTime: deltaTime)
    }
}

// MARK: Equatable, Hashable
extension RectangularStaticBody: Equatable, Hashable {
}
