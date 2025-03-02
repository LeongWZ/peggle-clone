import Foundation

protocol CircularCollidable: Collidable {
    var center: Position { get }
    var radius: Double { get }
    var restitution: Double { get }
}

extension CircularCollidable {
    var leftEdge: Double {
        center.xCartesian - radius
    }

    var rightEdge: Double {
        center.xCartesian + radius
    }

    var topEdge: Double {
        center.yCartesian - radius
    }

    var bottomEdge: Double {
        center.yCartesian + radius
    }

    func willCollide(with another: CircularCollidable) -> Bool {
        let distance = center.getDistance(to: another.center)
        return distance < (radius + another.radius)
    }

    func willCollide(with rectangle: RectangularCollidable) -> Bool {
        leftEdge < rectangle.rightEdge && rightEdge > rectangle.leftEdge
            && topEdge < rectangle.bottomEdge && bottomEdge > rectangle.topEdge
    }

    func willCollide(with triangle: TriangularCollidable) -> Bool {
        getCollisionPoint(with: triangle) != nil
    }

    func getCollisionPoint(with triangle: TriangularCollidable) -> Position? {
        for point in generate2DCircularMesh() where triangle.isPointInside(point: point) {
            return point
        }

        return nil
    }

    private func generate2DCircularMesh(n numberOfPoints: Int = 20) -> [Position] {
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
