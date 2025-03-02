import Foundation

/// A protocol that represents a peg model in the game.
/// Peg models are collidable objects that can be added to or removed from a board.
protocol PegModelable {
    var id: UUID { get }
    var boardId: UUID? { get }
    var radius: Double { get }
    var center: Position { get }
    var heading: Double { get }

    /// Determines whether the peg will collide with another peg.
    func willCollide(with other: PegModelable) -> Bool

    /// Adds the peg to a board. The board may choose to not add the peg.
    func addToBoard(board: BoardModel) -> BoardModel

    /// Removes the peg from a board.
    func removeFromBoard(board: BoardModel) -> BoardModel

    /// Moves the peg to a new location on the board.
    func moveOnBoard(board: BoardModel, to location: Position) -> (BoardModel, Self)

    /// Rotates the peg on the board.
    func rotateOnBoard(board: BoardModel, by angleRadians: Double) -> (BoardModel, Self)

    /// Scales the peg size on the board.
    func scalePegOnBoard(board: BoardModel, by scaleFactor: Double) -> (BoardModel, Self)

    /// Renders the peg using the specified renderer.
    func render(renderer: PegRenderer)

    func toCircularStaticBody() -> CircularStaticBody
}

extension PegModelable {
    /// Determines whether the peg will collide with another peg.
    func willCollide(with other: PegModelable) -> Bool {
        let distance = center.getDistance(to: other.center)
        return distance < (radius + other.radius)
    }

    func generate2DCircularMesh(n numberOfPoints: Int = 20) -> [Position] {
        var mesh: [Position] = []

        for theta in stride(from: 0, to: 2 * Double.pi, by: 2 * Double.pi / Double(numberOfPoints)) {
            let point = generatePointInCircle(angleRadians: theta)
            mesh.append(point)
        }

        return mesh
    }

    private func generatePointInCircle(angleRadians: Double) -> Position {
        let pointX = center.xCartesian + radius * cos(angleRadians)
        let pointY = center.yCartesian + radius * sin(angleRadians)
        return Position(xCartesian: pointX, yCartesian: pointY)
    }
}
