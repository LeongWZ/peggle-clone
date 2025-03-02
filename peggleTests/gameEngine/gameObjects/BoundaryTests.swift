import XCTest
@testable import peggle

class BoundaryTests: XCTestCase {

    func testIsBallOutOfBounds() {
        let boundary = Boundary(width: 100, height: 100)
        let ball = Ball(initialPosition: Position(xCartesian: 50, yCartesian: 150))

        XCTAssertTrue(
            boundary.isBallOutOfBounds(ball),
            "Ball should be out of bounds if its center yCartesian is greater than boundary height plus radius"
        )

        let inBoundsBall = Ball(initialPosition: Position(xCartesian: 50, yCartesian: 50))
        XCTAssertFalse(
            boundary.isBallOutOfBounds(inBoundsBall),
            "Ball should not be out of bounds if its center yCartesian is within boundary"
        )
    }
}
