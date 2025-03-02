import UIKit

class LevelViewController: UIViewController {
    private let levelQuery: LevelQuery? = CoreDataLevelQuery()

    private let levelMutation: LevelMutation? = CoreDataLevelMutation()

    private var currentLevel = LevelModel(id: UUID(), name: "") {
        didSet {
            levelNameLabel.text = currentLevel.name
        }
    }

    private var paletteState = PaletteState()

    private var boardViewController: BoardViewController?

    @IBOutlet private var levelDesignerView: UIView!

    @IBOutlet private var orangePegPaletteButton: UIButton!

    @IBOutlet private var bluePegPaletteButton: UIButton!

    @IBOutlet private var greenPegPaletteButton: UIButton!

    @IBOutlet private var triangularBlockPaletteButton: UIButton!

    @IBOutlet private var levelNameLabel: UILabel!

    @IBOutlet private var deletePaletteButton: UIButton!

    @IBOutlet private var onDragSegmentedControl: UISegmentedControl!

    @IBAction private func onOrangePegPaletteButtonPress(_ sender: UIButton) {
        if paletteState.mode == PaletteState.Mode.addPointPeg {
            paletteState.mode = nil
        } else {
            paletteState.mode = PaletteState.Mode.addPointPeg
        }
        updatePaletteButtonsOpacities()
    }

    @IBAction private func onBluePegPaletteButtonPress(_ sender: UIButton) {
        if paletteState.mode == PaletteState.Mode.addNormalPeg {
            paletteState.mode = nil
        } else {
            paletteState.mode = PaletteState.Mode.addNormalPeg
        }
        updatePaletteButtonsOpacities()
    }

    @IBAction private func onGreenPegPaletteButtonPress(_ sender: UIButton) {
        if paletteState.mode == PaletteState.Mode.addPowerUpPeg {
            paletteState.mode = nil
        } else {
            paletteState.mode = PaletteState.Mode.addPowerUpPeg
        }
        updatePaletteButtonsOpacities()
    }

    @IBAction private func onDeletePaletteButtonPress(_ sender: Any) {
        if paletteState.mode == PaletteState.Mode.delete {
            paletteState.mode = nil
        } else {
            paletteState.mode = PaletteState.Mode.delete
        }
        updatePaletteButtonsOpacities()
    }

    @IBAction private func onTriangularBlockPaletteButtonPress(_ sender: UIButton) {
        if paletteState.mode == PaletteState.Mode.addTriangularBlock {
            paletteState.mode = nil
        } else {
            paletteState.mode = PaletteState.Mode.addTriangularBlock
        }
        updatePaletteButtonsOpacities()
    }

    @IBAction private func onSave(_ sender: UIButton) {
        presentSaveLevelAlert()
    }

    @IBAction private func onReset(_ sender: UIButton) {
        let newBoard = currentLevel.board.reset()
        currentLevel = currentLevel.setBoard(newBoard)
        boardViewController?.reloadBoard()
    }

    @IBAction private func onDragValueChange(_ sender: UISegmentedControl) {
        paletteState.shouldRotateOnDrag = sender.selectedSegmentIndex == 1
    }

    @IBAction private func unwindWithSelectedLevel(_ segue: UIStoryboardSegue) {
    }

    @IBSegueAction func boardSegue(_ coder: NSCoder) -> BoardViewController? {
        boardViewController = BoardViewController(coder: coder, boardDelegate: self)
        return boardViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updatePaletteButtonsOpacities()
        onDragSegmentedControl.selectedSegmentIndex = paletteState.shouldRotateOnDrag ? 1 : 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "StartGameFromLevelDesigner":
            prepareForStartGame(for: segue)
        default:
            break
        }
    }

    private func updatePaletteButtonsOpacities() {
        bluePegPaletteButton.alpha = 0.5
        orangePegPaletteButton.alpha = 0.5
        greenPegPaletteButton.alpha = 0.5
        triangularBlockPaletteButton.alpha = 0.5
        deletePaletteButton.alpha = 0.5

        switch paletteState.mode {
        case .addNormalPeg:
            bluePegPaletteButton.alpha = 1
        case .addPointPeg:
            orangePegPaletteButton.alpha = 1
        case .addPowerUpPeg:
            greenPegPaletteButton.alpha = 1
        case .addTriangularBlock:
            triangularBlockPaletteButton.alpha = 1
        case .delete:
            deletePaletteButton.alpha = 1
        default:
            break
        }
    }

    private func prepareForStartGame(for segue: UIStoryboardSegue) {
        guard let gameLoadLevelDelegate = segue.destination as? GameLoadLevelDelegate else {
            return
        }

        gameLoadLevelDelegate.setLevel(currentLevel)
    }

    private func presentSaveLevelAlert() {
        let alert = UIAlertController(title: "Save Level", message: "Set a name for this level", preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in

            guard let textField = alert.textFields?.first,
                  let nameToSave = textField.text,
                  let currentLevel = self?.currentLevel.setName(nameToSave) else {
                return
            }

            do {
                self?.currentLevel = try self?.levelMutation?.upsertLevel(currentLevel) ?? currentLevel
            } catch {
                self?.showToast(message: "Failed to save", font: .systemFont(ofSize: 13))
                return
            }

            self?.showToast(message: "Saved!", font: .systemFont(ofSize: 13))
        }

        let saveAsNewAction = UIAlertAction(title: "Save as new", style: .default) { [weak self] _ in

            guard let textField = alert.textFields?.first,
                  let nameToSave = textField.text,
                  let currentLevel = self?.currentLevel.setName(nameToSave) else {
                return
            }

            do {
                self?.currentLevel = try self?.levelMutation?.createLevel(currentLevel) ?? currentLevel
            } catch {
                self?.showToast(message: "Failed to save", font: .systemFont(ofSize: 13))
                return
            }

            self?.showToast(message: "Saved!", font: .systemFont(ofSize: 13))
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(saveAsNewAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)

        alert.addTextField()

        if let textField = alert.textFields?.first {
            textField.text = currentLevel.name
            textField.placeholder = "Level Name"
        }

        let isLevelPreloaded = PreloadedLevelsHelper.isLevelPreloaded(currentLevel)
        saveAction.isEnabled = !isLevelPreloaded
    }

}

extension LevelViewController: LevelDesignerBoardDelegate {

    func getBoard() -> BoardModel {
        currentLevel.board
    }

    func setBoard(_ board: BoardModel) {
        currentLevel = currentLevel.setBoard(board)
    }

    func getPaletteState() -> PaletteState {
        paletteState
    }
}

extension LevelViewController: LevelDesignerLoadLevelDelegate {
    func setLevel(_ levelId: UUID) {
        let emptyLevel = LevelModel(id: levelId, name: "")

        // load view to get boundary width and height
        loadViewIfNeeded()
        let boundaryWidth = boardViewController?.view.bounds.width ?? 0
        let boundaryHeight = boardViewController?.view.bounds.height ?? 0

        currentLevel = levelQuery?.fetchByIdOrElseWithPreloadedLevels(
            levelId,
            emptyLevel,
            boundaryWidth: boundaryWidth,
            boundaryHeight: boundaryHeight) ?? emptyLevel

        boardViewController?.reloadBoard()
    }

    func setNewLevel() {
        currentLevel = LevelModel(id: UUID(), name: "")
        boardViewController?.reloadBoard()
    }
}
