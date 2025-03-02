protocol TriangularCollidable: Collidable {
    var firstPoint: Position { get }
    var secondPoint: Position { get }
    var thirdPoint: Position { get }
    var restitution: Double { get }
}

extension TriangularCollidable {

    var centroid: Position {
        Position(
            xCartesian: (firstPoint.xCartesian + secondPoint.xCartesian + thirdPoint.xCartesian) / 3,
            yCartesian: (firstPoint.yCartesian + secondPoint.yCartesian + thirdPoint.yCartesian) / 3
        )
    }

    /// Source: https://stackoverflow.com/a/20861130
    func isPointInside(point: Position) -> Bool {
        let s = (firstPoint.xCartesian - thirdPoint.xCartesian) * (point.yCartesian - thirdPoint.yCartesian)
            - (firstPoint.yCartesian - thirdPoint.yCartesian) * (point.xCartesian - thirdPoint.xCartesian)

        let t = (secondPoint.xCartesian - firstPoint.xCartesian) * (point.yCartesian - firstPoint.yCartesian)
            - (secondPoint.yCartesian - firstPoint.yCartesian) * (point.xCartesian - firstPoint.xCartesian)

        if (s < 0) != (t < 0) && s != 0 && t != 0 {
            return false
        }

        let d = (thirdPoint.xCartesian - secondPoint.xCartesian) * (point.yCartesian - secondPoint.yCartesian)
            - (thirdPoint.yCartesian - secondPoint.yCartesian) * (point.xCartesian - secondPoint.xCartesian)

        return d == 0 || (d < 0) == (s + t <= 0)
    }
}
