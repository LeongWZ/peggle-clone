protocol Movable {
    var mass: Double { get }
    var center: Position { get }

    func move(externalForces: [Force], deltaTime: Double) -> Self
}

extension Movable {
    func getWeight(g gravitationalAcceleration: Double) -> Force {
        Force(fx: 0, fy: mass * gravitationalAcceleration)
    }
}
