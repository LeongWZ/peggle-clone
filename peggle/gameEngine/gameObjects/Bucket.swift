struct Bucket {
    static let Width: Double = 180
    static let Height: Double = 200
    private static let Restitution: Double = 1
    private static let Mass: Double = 100
    private static let InitialVelocity = Velocity(vx: 200, vy: 0)

    let hasBall: Bool

    let rectangularFreeBody: RectangularFreeBody

    var center: Position {
        rectangularFreeBody.center
    }

    var width: Double {
        rectangularFreeBody.width
    }

    var height: Double {
        rectangularFreeBody.height
    }

    init(center: Position) {
        rectangularFreeBody = RectangularFreeBody(
            center: center,
            mass: Bucket.Mass,
            width: Bucket.Width,
            height: Bucket.Height,
            restitution: Bucket.Restitution,
            velocity: Bucket.InitialVelocity
        )
        hasBall = false
    }

    init(rectangularFreeBody: RectangularFreeBody, hasBall: Bool) {
        self.rectangularFreeBody = rectangularFreeBody
        self.hasBall = hasBall
    }

    func setRectangularFreeBody(_ rectangularFreeBody: RectangularFreeBody) -> Bucket {
        Bucket(rectangularFreeBody: rectangularFreeBody, hasBall: hasBall)
    }

    func setPosition(_ position: Position) -> Bucket {
        setRectangularFreeBody(rectangularFreeBody.setPosition(position))
    }

    func observe(ball: Ball?) -> Bucket {
        guard let ball = ball else {
            return Bucket(rectangularFreeBody: rectangularFreeBody, hasBall: false)
        }

        return Bucket(rectangularFreeBody: rectangularFreeBody, hasBall: contains(ball: ball))
    }

    private func contains(ball: Ball) -> Bool {
        let bottomEdgeOfBall = ball.center.yCartesian + ball.radius
        let leftEdgeOfBall = ball.center.xCartesian - ball.radius
        let rightEdgeOfBall = ball.center.xCartesian + ball.radius

        return bottomEdgeOfBall >= rectangularFreeBody.topEdge
            && leftEdgeOfBall >= rectangularFreeBody.leftEdge
            && rightEdgeOfBall <= rectangularFreeBody.rightEdge
    }
}
