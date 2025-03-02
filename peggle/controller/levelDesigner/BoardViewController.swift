import UIKit

class BoardViewController: UIViewController {

    private weak var boardDelegate: LevelDesignerBoardDelegate?

    private var board: BoardModel {
        boardDelegate?.getBoard() ?? BoardModel(id: UUID(), levelId: nil, normalPegs: [],
                                                pointPegs: [], powerUpPegs: [], triangularBlocks: [])
    }

    @IBOutlet private var boardView: UIView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    convenience init?(coder: NSCoder, boardDelegate: LevelDesignerBoardDelegate) {
        self.init(coder: coder)
        self.boardDelegate = boardDelegate
    }

    @IBAction private func onTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)

        if boardDelegate?.getPaletteState().mode == .addTriangularBlock {
            createBlockView(at: location)
            return
        }

        createPegView(at: location)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadPegs()
        loadBlocks()
    }

    func reloadBoard() {
        clearPegs()
        clearTriangularBlocks()
        loadPegs()
        loadBlocks()
    }

    private func loadPegs() {
        for peg in board.allPegs {
            peg.render(renderer: self)
        }
    }

    private func clearPegs() {
        boardView.subviews
            .compactMap { subview in subview as? PegView }
            .forEach { pegView in pegView.removeFromSuperview() }
    }

    private func loadBlocks() {
        for block in board.triangularBlocks {
            block.render(renderer: self)
        }
    }

    private func clearTriangularBlocks() {
        boardView.subviews
            .compactMap { subview in subview as? TriangularBlockView }
            .forEach { triangleBlockView in triangleBlockView.removeFromSuperview() }
    }

    private func willAddedPegBeWithinBounds(_ peg: PegModelable) -> Bool {
        let minX = view.bounds.minX + peg.radius
        let maxX = view.bounds.maxX - peg.radius

        let minY = view.bounds.minY + peg.radius
        let maxY = view.bounds.maxY - peg.radius

        return peg.center.xCartesian >= minX
            && peg.center.xCartesian <= maxX
            && peg.center.yCartesian >= minY
            && peg.center.yCartesian <= maxY
    }

    private func createPegView(at location: CGPoint) {
        guard let newPeg = createPeg(at: location),
              willAddedPegBeWithinBounds(newPeg),
              addPegToBoard(peg: newPeg) else {
            return
        }

        newPeg.render(renderer: self)
    }

    private func createPeg(at location: CGPoint) -> PegModelable? {
        let position = Position(xCartesian: location.x, yCartesian: location.y)

        if boardDelegate?.getPaletteState().mode == .addNormalPeg {
            return NormalPegModel.ofDefault(id: UUID(), boardId: board.id, center: position)
        }

        if boardDelegate?.getPaletteState().mode == .addPointPeg {
            return PointPegModel.ofDefault(id: UUID(), boardId: board.id, center: position)
        }

        if boardDelegate?.getPaletteState().mode == .addPowerUpPeg {
            return PowerUpPegModel.ofDefault(id: UUID(), boardId: board.id, center: position)
        }

        return nil
    }

    private func addPegToBoard(peg: PegModelable) -> Bool {
        let newBoard = peg.addToBoard(board: board)

        if board == newBoard {
            // peg was not added
            return false
        }

        boardDelegate?.setBoard(newBoard)
        return true
    }

    private func createBlockView(at location: CGPoint) {
        let position = Position(xCartesian: location.x, yCartesian: location.y)

        let newTriangularBlock = TriangularBlockModel.ofDefault(centroid: position, boardId: board.id)

        guard willAddedBlockBeWithinBounds(newTriangularBlock) else {
            return
        }

        guard addTriangularBlockToBoard(block: newTriangularBlock) else {
            return
        }

        newTriangularBlock.render(renderer: self)
    }

    private func willAddedBlockBeWithinBounds(_ block: TriangularBlockModel) -> Bool {
        let minX = view.bounds.minX + block.width / 2
        let maxX = view.bounds.maxX - block.width / 2

        let minY = view.bounds.minY + block.height / 2
        let maxY = view.bounds.maxY - block.height / 2

        return block.centroid.xCartesian >= minX
            && block.centroid.xCartesian <= maxX
            && block.centroid.yCartesian >= minY
            && block.centroid.yCartesian <= maxY
    }

    private func addTriangularBlockToBoard(block: TriangularBlockModel) -> Bool {
        let newBoard = board.addTriangularBlock(block: block)

        if board == newBoard {
            // block was not added
            return false
        }

        boardDelegate?.setBoard(newBoard)
        return true
    }
}

extension BoardViewController: LevelDesignerDeletePegDelegate, LevelDesignerUpdatePegDelegate {
    var shouldRotatePegOnDrag: Bool {
        guard let paletteState = boardDelegate?.getPaletteState() else {
            return false
        }

        return paletteState.shouldRotateOnDrag
    }

    func deletePegOnTap(peg: PegModelable) -> Bool {
        guard let paletteState = boardDelegate?.getPaletteState() else {
            return false
        }

        if paletteState.mode != .delete {
            return false
        }

        let newBoard = peg.removeFromBoard(board: board)
        boardDelegate?.setBoard(newBoard)
        return true
    }

    func deletePegOnLongPress(peg: PegModelable) {
        let newBoard = peg.removeFromBoard(board: board)
        boardDelegate?.setBoard(newBoard)
    }

    func movePeg(peg: PegModelable, to point: CGPoint) -> PegModelable {
        let position = Position(xCartesian: point.x, yCartesian: point.y)
        let (newBoard, movedPeg) = peg.moveOnBoard(board: board, to: position)

        boardDelegate?.setBoard(newBoard)
        return movedPeg
    }

    func rotatePeg(peg: PegModelable, by angleRadians: CGFloat) -> PegModelable {
        let (newBoard, rotatedPeg) = peg.rotateOnBoard(board: board, by: angleRadians)
        boardDelegate?.setBoard(newBoard)
        return rotatedPeg
    }

    func scalePeg(peg: PegModelable, by scaleFactor: Double) -> PegModelable {
        let (newBoard, scaledPeg) = peg.scalePegOnBoard(board: board, by: scaleFactor)
        boardDelegate?.setBoard(newBoard)
        return scaledPeg
    }
}

extension BoardViewController: PegRenderer {

    func render(peg: NormalPegModel) {
        let pegView = BluePegView(peg: peg, deletePegDelegate: self, updatePegDelegate: self, hasGestures: true)
        view.addSubview(pegView)
    }

    func render(peg: PointPegModel) {
        let pegView = OrangePegView(peg: peg, deletePegDelegate: self, updatePegDelegate: self, hasGestures: true)
        view.addSubview(pegView)
    }

    func render(peg: PowerUpPegModel) {
        let pegView = GreenPegView(peg: peg, deletePegDelegate: self, updatePegDelegate: self, hasGestures: true)
        view.addSubview(pegView)
    }
}

extension BoardViewController: LevelDesignerDeleteTriangularBlockDelegate {
    func deleteTriangularBlockOnTap(triangularBlock: TriangularBlockModel) -> Bool {
        guard let paletteState = boardDelegate?.getPaletteState() else {
            return false
        }

        if paletteState.mode != .delete {
            return false
        }

        let newBoard = board.removeTriangularBlock(block: triangularBlock)
        boardDelegate?.setBoard(newBoard)
        return true
    }

    func deleteTriangularBlockOnLongPress(triangularBlock: TriangularBlockModel) {
        let newBoard = board.removeTriangularBlock(block: triangularBlock)
        boardDelegate?.setBoard(newBoard)
    }
}

extension BoardViewController: BlockRenderer {
    func render(block: TriangularBlockModel) {
        let blockView = TriangularBlockView(
            triangularBlock: block,
            deleteTriangularBlockDelegate: self,
            updateTriangularBlockDelegate: self,
            hasGestures: true
        )
        view.addSubview(blockView)
    }
}

extension BoardViewController: LevelDesignerUpdateTriangularBlockDelegate {
    var shouldRotateBlockOnDrag: Bool {
        guard let paletteState = boardDelegate?.getPaletteState() else {
            return false
        }

        return paletteState.shouldRotateOnDrag
    }

    func moveTriangularBlockCenter(triangularBlock: TriangularBlockModel, to point: CGPoint) -> TriangularBlockModel {
        let position = Position(xCartesian: point.x, yCartesian: point.y)
        let (newBoard, movedBlock) = triangularBlock.moveOnBoard(board: board, to: position)

        boardDelegate?.setBoard(newBoard)
        return movedBlock
    }

    func moveTriangularBlockFirstPoint(triangularBlock: TriangularBlockModel,
                                       to point: CGPoint) -> TriangularBlockModel {
        let position = Position(xCartesian: point.x, yCartesian: point.y)
        let (newBoard, movedBlock) = board.moveTriangularBlock(
            blockToMove: triangularBlock,
            movedBlock: triangularBlock.setFirstPoint(position)
        )

        boardDelegate?.setBoard(newBoard)
        return movedBlock
    }

    func moveTriangularBlockSecondPoint(triangularBlock: TriangularBlockModel,
                                        to point: CGPoint) -> TriangularBlockModel {
        let position = Position(xCartesian: point.x, yCartesian: point.y)
        let (newBoard, movedBlock) = board.moveTriangularBlock(
            blockToMove: triangularBlock,
            movedBlock: triangularBlock.setSecondPoint(position)
        )

        boardDelegate?.setBoard(newBoard)
        return movedBlock
    }

    func moveTriangularBlockThirdPoint(triangularBlock: TriangularBlockModel,
                                       to point: CGPoint) -> TriangularBlockModel {
        let position = Position(xCartesian: point.x, yCartesian: point.y)
        let (newBoard, movedBlock) = board.moveTriangularBlock(
            blockToMove: triangularBlock,
            movedBlock: triangularBlock.setThirdPoint(position)
        )

        boardDelegate?.setBoard(newBoard)
        return movedBlock
    }

    func rotateTriangularBlock(triangularBlock: TriangularBlockModel,
                               by angleRadians: CGFloat) -> TriangularBlockModel {
        let (newBoard, rotatedBlock) = triangularBlock.rotateOnBoard(board: board, by: angleRadians)
        boardDelegate?.setBoard(newBoard)
        return rotatedBlock
    }

}
