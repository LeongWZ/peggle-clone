import Foundation

struct Ball {

    private static let Mass: Double = 10.0
    private static let Radius: Double = 32.0
    private static let PastVelocitiesCount: Int = 5
    private static let MinimumVelocityMagnitude: Double = 20

    let circularBody: CircularFreeBody
    private let previousVelocities: [Velocity]

    var center: Position {
        circularBody.center
    }

    var radius: Double {
        circularBody.radius
    }

    init(initialPosition: Position) {
        circularBody = CircularFreeBody(center: initialPosition, mass: Ball.Mass, radius: Ball.Radius, restitution: 1)
        previousVelocities = []
    }

    init(circularBody: CircularFreeBody, previousVelocities: [Velocity]) {
        self.circularBody = circularBody
        self.previousVelocities = previousVelocities
    }

    func setCircularBody(_ circularBody: CircularFreeBody) -> Self {
        Ball(
            circularBody: circularBody,
            previousVelocities: recordVelocity(circularBody.freeBody.velocity)
        )
    }

    func setCenter(_ center: Position) -> Self {
        setCircularBody(circularBody.setPosition(center))
    }

    func isStuck() -> Bool {
        previousVelocities.allSatisfy { velocity in velocity.magnitude < Ball.MinimumVelocityMagnitude }
    }

    private func recordVelocity(_ velocity: Velocity) -> [Velocity] {
        assert(Ball.PastVelocitiesCount > 0, "Past velocities count must be positive")

        if previousVelocities.count < Ball.PastVelocitiesCount {
            return previousVelocities + [velocity]
        }

        return previousVelocities.dropFirst() + [velocity]
    }

 }

// MARK: Equatable, Hashable
extension Ball: Equatable, Hashable {
}
