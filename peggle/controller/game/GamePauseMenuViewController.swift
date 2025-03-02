import UIKit

class GamePauseMenuViewController: UIViewController {
    static let SegueIdentifierFromGameLevelController = "ShowPauseMenuForGame"

    private weak var gameResumeDelgate: GameResumeDelegate?

    private weak var gameResetDelegate: GameResetDelegate?

    private weak var gameGoToMainMenuDelegate: GameGoToMainMenuDelegate?

    @IBOutlet private var resumeButton: UIButton!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init?(coder: NSCoder, gameResumeDelegate: GameResumeDelegate, gameResetDelegate: GameResetDelegate,
          gameGoToMainMenuDelegate: GameGoToMainMenuDelegate) {
        self.gameResumeDelgate = gameResumeDelegate
        self.gameResetDelegate = gameResetDelegate
        self.gameGoToMainMenuDelegate = gameGoToMainMenuDelegate
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        resumeButton.isEnabled = gameResumeDelgate?.isGameStateOngoing ?? false
    }

    @IBAction private func onResetButtonPress(_ sender: UIButton) {
        gameResetDelegate?.resetGame()
        self.dismiss(animated: true)
    }

    @IBAction private func onMainMenuButtonPress(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Exit to Main Menu?",
            message: "You will lose all unsaved progress. Are you sure?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { _ in
            self.dismiss(animated: false)
            self.gameGoToMainMenuDelegate?.goToMainMenu()
        })

        present(alert, animated: true)
    }

    @IBAction private func onResumeButtonPress(_ sender: UIButton) {
        gameResumeDelgate?.resumeGame()
        dismiss(animated: true)
    }
}
