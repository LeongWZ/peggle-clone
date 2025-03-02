struct Wall {
    private static let Restitution: Double = 1

    let rectangularStaticBody: RectangularStaticBody

    var width: Double {
        rectangularStaticBody.width
    }

    var height: Double {
        rectangularStaticBody.height
    }

    init(center: Position, width: Double, height: Double) {
        rectangularStaticBody = RectangularStaticBody(
            center: center,
            width: width,
            height: height,
            restitution: Wall.Restitution
        )
    }
}

// MARK: Equatable, Hashable
extension Wall: Equatable, Hashable {
}
