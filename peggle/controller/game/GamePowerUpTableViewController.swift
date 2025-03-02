import UIKit

class GamePowerUpTableViewController: UITableViewController {
    static let SegueIdentifierFromGameLevelController = "ShowPowerUpsFromGame"

    private weak var gameActivatePowerUpDelegate: GameActivatePowerUpDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init?(coder: NSCoder, gameActivatePowerUpDelegate: GameActivatePowerUpDelegate) {
        self.gameActivatePowerUpDelegate = gameActivatePowerUpDelegate
        super.init(coder: coder)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "PickKaBoomPowerUp":
            gameActivatePowerUpDelegate?.activatePowerUp(powerUp: KaBoomPowerUp())
        case "PickSpookyBallPowerUp":
            gameActivatePowerUpDelegate?.activatePowerUp(powerUp: SpookyBallPowerUp())
        default:
            break
        }
    }
}
