protocol Collidable {
    func onCollision(circularCollidable: CircularCollidable, deltaTime: Double) -> Self

    func onCollision(rectangularCollidable: RectangularCollidable, deltaTime: Double) -> Self

    func onCollision(triangularCollidable: TriangularCollidable, deltaTime: Double) -> Self
}
