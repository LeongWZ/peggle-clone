struct PaletteState {
    var mode: Mode?

    var shouldRotateOnDrag: Bool = false

    enum Mode {
        case addNormalPeg
        case addPointPeg
        case addPowerUpPeg
        case addTriangularBlock
        case delete
    }
}
