import XCTest
@testable import peggle

class PositionTests: XCTestCase {

    func testUpdate() {
        let initialPosition = Position(xCartesian: 0, yCartesian: 0)
        let velocity = Velocity(vx: 10, vy: 5)
        let deltaTime = 2.0

        let updatedPosition = initialPosition.update(using: velocity, deltaTime: deltaTime)

        XCTAssertEqual(updatedPosition.xCartesian, 20, "The xCartesian should be updated correctly")
        XCTAssertEqual(updatedPosition.yCartesian, 10, "The yCartesian should be updated correctly")
    }

    func testGetDistance() {
        let position1 = Position(xCartesian: 0, yCartesian: 0)
        let position2 = Position(xCartesian: 3, yCartesian: 4)

        let distance = position1.getDistance(to: position2)

        XCTAssertEqual(distance, 5, "The distance between the two positions should be 5")
    }

    func testToCGPoint() {
        let position = Position(xCartesian: 10, yCartesian: 20)

        let cgPoint = position.toCGPoint()

        XCTAssertEqual(cgPoint.x, 10, "The x value of the CGPoint should be 10")
        XCTAssertEqual(cgPoint.y, 20, "The y value of the CGPoint should be 20")
    }

    func testEquatable() {
        let position1 = Position(xCartesian: 10, yCartesian: 20)
        let position2 = Position(xCartesian: 10, yCartesian: 20)
        let position3 = Position(xCartesian: 15, yCartesian: 25)

        XCTAssertEqual(position1, position2, "Positions with the same coordinates should be equal")
        XCTAssertNotEqual(position1, position3, "Positions with different coordinates should not be equal")
    }

    func testHashable() {
        let position1 = Position(xCartesian: 10, yCartesian: 20)
        let position2 = Position(xCartesian: 10, yCartesian: 20)

        XCTAssertEqual(position1.hashValue, position2.hashValue,
                       "Positions with the same coordinates should have the same hash value")
    }
}
