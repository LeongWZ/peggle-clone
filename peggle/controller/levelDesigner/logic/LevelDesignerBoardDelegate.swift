protocol LevelDesignerBoardDelegate: AnyObject {
    func getBoard() -> BoardModel

    func setBoard(_ board: BoardModel)

    func getPaletteState() -> PaletteState
}
