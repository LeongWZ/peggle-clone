import XCTest
@testable import peggle

class VelocityTests: XCTestCase {

    func testUpdate() {
        let initialVelocity = Velocity(vx: 10, vy: 5)
        let acceleration = Acceleration(ax: 2, ay: 3)
        let deltaTime = 2.0

        let updatedVelocity = initialVelocity.update(using: acceleration, deltaTime: deltaTime)

        XCTAssertEqual(updatedVelocity.vx, 14, "The vx should be updated correctly")
        XCTAssertEqual(updatedVelocity.vy, 11, "The vy should be updated correctly")
    }

    func testMagnitude() {
        let velocity = Velocity(vx: 3, vy: 4)

        let magnitude = velocity.magnitude

        XCTAssertEqual(magnitude, 5, "The magnitude of the velocity should be 5")
    }

    func testNormalize() {
        let velocity = Velocity(vx: 3, vy: 4)

        let normalizedVelocity = velocity.normalize()

        XCTAssertEqual(normalizedVelocity.vx, 0.6, accuracy: 0.0001, "The vx of the normalized velocity should be 0.6")
        XCTAssertEqual(normalizedVelocity.vy, 0.8, accuracy: 0.0001, "The vy of the normalized velocity should be 0.8")
    }

    func testScale() {
        let velocity = Velocity(vx: 3, vy: 4)
        let scale = 2.0

        let scaledVelocity = velocity.scale(by: scale)

        XCTAssertEqual(scaledVelocity.vx, 6, "The vx of the scaled velocity should be 6")
        XCTAssertEqual(scaledVelocity.vy, 8, "The vy of the scaled velocity should be 8")
    }

    func testEquatable() {
        let velocity1 = Velocity(vx: 3, vy: 4)
        let velocity2 = Velocity(vx: 3, vy: 4)
        let velocity3 = Velocity(vx: 5, vy: 6)

        XCTAssertEqual(velocity1, velocity2, "Velocities with the same components should be equal")
        XCTAssertNotEqual(velocity1, velocity3, "Velocities with different components should not be equal")
    }

    func testHashable() {
        let velocity1 = Velocity(vx: 3, vy: 4)
        let velocity2 = Velocity(vx: 3, vy: 4)

        XCTAssertEqual(velocity1.hashValue, velocity2.hashValue,
                       "Velocities with the same components should have the same hash value")
    }
}
