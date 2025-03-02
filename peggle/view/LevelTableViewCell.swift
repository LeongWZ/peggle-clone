import UIKit
import Foundation

class LevelTableViewCell: UITableViewCell {

    static let identifier: String = "LevelTableViewCell"

    @IBOutlet private var levelLabel: UILabel?

    private var levelId: UUID?

    private var levelName: String? {
        didSet {
            levelLabel?.text = levelName
        }
    }

    func setLevel(levelId: UUID, levelName: String) {
        self.levelId = levelId
        self.levelName = levelName
    }

    func getLevelId() -> UUID? {
        levelId
    }
}
