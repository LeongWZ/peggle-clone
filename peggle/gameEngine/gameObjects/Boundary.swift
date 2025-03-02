struct Boundary {
    private static let WallThickness: Double = 1_000

    let width: Double
    let height: Double

    private let leftWall: Wall
    private let rightWall: Wall
    private let topWall: Wall

    init(width: Double, height: Double) {
        self.width = width
        self.height = height

        let center = Position(xCartesian: width / 2, yCartesian: height / 2)

        leftWall = Wall(
            center: Position(xCartesian: -Boundary.WallThickness / 2, yCartesian: center.yCartesian),
            width: Boundary.WallThickness,
            height: height
        )

        rightWall = Wall(
            center: Position(xCartesian: width + Boundary.WallThickness / 2, yCartesian: center.yCartesian),
            width: Boundary.WallThickness,
            height: height
        )

        topWall = Wall(
            center: Position(xCartesian: center.xCartesian, yCartesian: -Boundary.WallThickness / 2),
            width: width,
            height: Boundary.WallThickness
        )
    }

    var walls: [Wall] {
        [leftWall, rightWall, topWall]
    }

    func isBallOutOfBounds(_ ball: Ball) -> Bool {
        ball.center.yCartesian >= height + ball.radius
            || ball.center.yCartesian <= -ball.radius
            || ball.center.xCartesian >= width + ball.radius
            || ball.center.xCartesian <= -ball.radius
    }
}

// MARK: Equatable, Hashable
extension Boundary: Equatable, Hashable {
}
