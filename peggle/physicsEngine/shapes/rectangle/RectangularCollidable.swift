protocol RectangularCollidable: Collidable {
    var center: Position { get }
    var width: Double { get }
    var height: Double { get }
    var restitution: Double { get }
}

extension RectangularCollidable {
    var leftEdge: Double {
        center.xCartesian - width / 2
    }

    var rightEdge: Double {
        center.xCartesian + width / 2
    }

    var topEdge: Double {
        center.yCartesian - height / 2
    }

    var bottomEdge: Double {
        center.yCartesian + height / 2
    }

    func willCollide(with other: RectangularCollidable) -> Bool {
        leftEdge <= other.rightEdge && rightEdge >= other.leftEdge
            && topEdge <= other.bottomEdge && bottomEdge >= other.topEdge
    }
}
