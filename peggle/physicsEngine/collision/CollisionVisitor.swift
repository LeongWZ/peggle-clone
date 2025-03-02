protocol CollisionVisitor {
    func visitCollision<T: Collidable>(with: T, deltaTime: Double) -> T
}
