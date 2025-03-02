protocol PegRenderer {
    func render(peg: NormalPegModel)

    func render(peg: PointPegModel)

    func render(peg: PowerUpPegModel)
}
