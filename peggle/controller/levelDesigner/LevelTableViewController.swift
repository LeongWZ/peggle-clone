import UIKit

class LevelTableViewController: UITableViewController {

    private let levelQuery: LevelQuery? = CoreDataLevelQuery()

    private var levels: [LevelModel] {
        levelQuery?.fetchOrElseWithPreloadedLevels([], boundaryWidth: 0, boundaryHeight: 0) ?? []
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        levels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let level = levels[indexPath.row]
        let isLevelPreloaded = PreloadedLevelsHelper.isLevelPreloaded(level)
        let levelName = isLevelPreloaded ? (level.name + " - Preloaded") : level.name

        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: LevelTableViewCell.identifier) as? LevelTableViewCell
        else {
            let newCell = LevelTableViewCell(style: .default, reuseIdentifier: LevelTableViewCell.identifier)
            newCell.setLevel(
                levelId: level.id,
                levelName: levelName
            )
            return newCell
        }

        cell.setLevel(levelId: level.id, levelName: levelName)
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "PickLevel":
            prepareForPickLevel(for: segue, sender: sender)
        case "NewLevel":
            prepareForNewLevel(for: segue, sender: sender)
        default:
            break
        }
    }

    private func prepareForPickLevel(for segue: UIStoryboardSegue, sender: Any?) {
        guard let levelCell = sender as? LevelTableViewCell,
              let loadLevelDelegate = segue.destination as? LevelDesignerLoadLevelDelegate  else {
            return
        }

        guard let levelId = levelCell.getLevelId() else {
            loadLevelDelegate.setNewLevel()
            return
        }

        loadLevelDelegate.setLevel(levelId)
    }

    private func prepareForNewLevel(for segue: UIStoryboardSegue, sender: Any?) {
        guard let loadLevelDelegate = segue.destination as? LevelDesignerLoadLevelDelegate  else {
            return
        }

        loadLevelDelegate.setNewLevel()
    }
}
