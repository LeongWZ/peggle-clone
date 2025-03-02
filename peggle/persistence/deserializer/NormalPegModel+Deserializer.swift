import Foundation

extension NormalPegModel {

    init(pegEntity: NormalPegEntity) {
        let id = pegEntity.id ?? UUID()
        let boardId = pegEntity.board?.id
        let center = Position(xCartesian: pegEntity.xCartesian, yCartesian: pegEntity.yCartesian)
        let radius = pegEntity.radius
        let heading = pegEntity.heading

        self.init(id: id, boardId: boardId, center: center, radius: radius, heading: heading)
    }
}
