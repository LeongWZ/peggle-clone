import Foundation

protocol GameLoadLevelDelegate: AnyObject {
    func setLevel(_ level: LevelModel)

    func setLevel(_ levelId: UUID)
}
