import Foundation

protocol LevelDesignerLoadLevelDelegate: AnyObject {
    func setLevel(_ levelId: UUID)

    func setNewLevel()
}
