import UIKit

class GameLevelViewController: UIViewController {

    private var gameManager: IGameManager?

    private var shouldGamePause: Bool = false

    @IBOutlet private var startButton: UIButton!

    @IBOutlet private var darkModeSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Detect when the app is backgrounded
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification, object: nil
        )

        darkModeSwitch.isOn = ThemeManager.getInstance()
            .hasTheme(DarkTheme.getInstance())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performSegue(withIdentifier: GamePowerUpTableViewController.SegueIdentifierFromGameLevelController,
                     sender: self)
    }

    @objc func appWillResignActive() {
        gameManager?.stopLoop()

        performSegue(withIdentifier: GamePauseMenuViewController.SegueIdentifierFromGameLevelController,
                     sender: self)
    }

    @IBAction private func unwindWithSelectedPowerUp(_ segue: UIStoryboardSegue) {
    }

    @IBSegueAction func boardSegue(_ coder: NSCoder) -> GameBoardViewController? {
        let gameBoardViewController = GameBoardViewController(coder: coder)
        gameManager = gameBoardViewController
        return gameBoardViewController
    }

    @IBAction private func onDarkModeSwitchChange(_ sender: UISwitch) {
        let themeManager = ThemeManager.getInstance()

        if sender.isOn {
            themeManager.activate(theme: DarkTheme.getInstance(), window: view.window)
        } else {
            themeManager.activate(theme: LightTheme.getInstance(), window: view.window)
        }
    }

    @IBSegueAction func pauseMenuSegue(_ coder: NSCoder) -> GamePauseMenuViewController? {
        shouldGamePause = true
        gameManager?.stopLoop()
        return GamePauseMenuViewController(
            coder: coder,
            gameResumeDelegate: self,
            gameResetDelegate: self,
            gameGoToMainMenuDelegate: self
        )
    }

    @IBSegueAction func powerUpTableSegue(_ coder: NSCoder) -> GamePowerUpTableViewController? {
        GamePowerUpTableViewController(coder: coder, gameActivatePowerUpDelegate: self)
    }

}

extension GameLevelViewController: GameLoadLevelDelegate {

    func setLevel(_ levelId: UUID) {
        // load view to intialize gameBoardViewController
        loadViewIfNeeded()
        gameManager?.setLevel(levelId)
    }

    func setLevel(_ level: LevelModel) {
        // load view to intialize gameBoardViewController
        loadViewIfNeeded()
        gameManager?.setLevel(level)
    }

}

extension GameLevelViewController: GameGoToMainMenuDelegate {
    func goToMainMenu() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension GameLevelViewController: GameResetDelegate {
    func resetGame() {
        gameManager?.resetGame()
        startButton.isEnabled = true
    }
}

extension GameLevelViewController: GameResumeDelegate {

    var isGameStateOngoing: Bool {
        gameManager?.isGameOngoing ?? false
    }

    func resumeGame() {
        shouldGamePause = false
        startCountdownToResumeGame()
        startButton.isEnabled = false
    }

    private func startCountdownToResumeGame() {
        var countdown = 3
        let countdownLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        countdownLabel.center = view.center
        countdownLabel.textAlignment = .center
        countdownLabel.font = UIFont.systemFont(ofSize: 200)
        countdownLabel.textColor = .white
        view.addSubview(countdownLabel)

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            countdownLabel.backgroundColor = .systemGray
            countdownLabel.text = "\(countdown)"
            countdown -= 1

            if countdown >= 0 {
                return
            }

            timer.invalidate()
            countdownLabel.removeFromSuperview()

            if self.shouldGamePause {
                return
            }

            self.gameManager?.startLoop()
        }
    }
}

extension GameLevelViewController: GameActivatePowerUpDelegate {
    func activatePowerUp(powerUp: GamePowerUp) {
        gameManager?.activatePowerUp(powerUp: powerUp)
        gameManager?.startLoop()
        startButton.isEnabled = false
        shouldGamePause = false
    }
}
