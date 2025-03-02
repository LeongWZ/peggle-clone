import XCTest
@testable import peggle

class ForceTests: XCTestCase {

    func testMagnitude() {
        let force = Force(fx: 3, fy: 4)

        let magnitude = force.magnitude

        XCTAssertEqual(magnitude, 5, "The magnitude of the force should be 5")
    }

    func testScale() {
        let force = Force(fx: 3, fy: 4)
        let scalar = 2.0

        let scaledForce = force.scale(by: scalar)

        XCTAssertEqual(scaledForce.fx, 6, "The fx of the scaled force should be 6")
        XCTAssertEqual(scaledForce.fy, 8, "The fy of the scaled force should be 8")
    }

    func testNormalize() {
        let force = Force(fx: 3, fy: 4)

        let normalizedForce = force.normalize()

        XCTAssertEqual(normalizedForce.fx, 0.6, accuracy: 0.0001, "The fx of the normalized force should be 0.6")
        XCTAssertEqual(normalizedForce.fy, 0.8, accuracy: 0.0001, "The fy of the normalized force should be 0.8")
    }

    func testGetResultantForce() {
        let force1 = Force(fx: 1, fy: 2)
        let force2 = Force(fx: 3, fy: 4)
        let forces = [force1, force2]

        let resultantForce = Force.getResultantForce(forces: forces)

        XCTAssertEqual(resultantForce.fx, 4, "The fx of the resultant force should be 4")
        XCTAssertEqual(resultantForce.fy, 6, "The fy of the resultant force should be 6")
    }

    func testEquatable() {
        let force1 = Force(fx: 3, fy: 4)
        let force2 = Force(fx: 3, fy: 4)
        let force3 = Force(fx: 5, fy: 6)

        XCTAssertEqual(force1, force2, "Forces with the same components should be equal")
        XCTAssertNotEqual(force1, force3, "Forces with different components should not be equal")
    }

    func testHashable() {
        let force1 = Force(fx: 3, fy: 4)
        let force2 = Force(fx: 3, fy: 4)

        XCTAssertEqual(force1.hashValue, force2.hashValue,
                       "Forces with the same components should have the same hash value")
    }
}
