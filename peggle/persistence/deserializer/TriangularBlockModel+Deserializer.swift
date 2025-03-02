import Foundation

extension TriangularBlockModel {

    init(triangularBlockEntity: TriangularBlockEntity) {
        let id = triangularBlockEntity.id ?? UUID()
        let boardId = triangularBlockEntity.board?.id

        let firstPoint = Position(
            xCartesian: triangularBlockEntity.firstXCartesian,
            yCartesian: triangularBlockEntity.firstYCartesian
        )

        let secondPoint = Position(
            xCartesian: triangularBlockEntity.secondXCartesian,
            yCartesian: triangularBlockEntity.secondYCartesian
        )

        let thirdPoint = Position(
            xCartesian: triangularBlockEntity.thirdXCartesian,
            yCartesian: triangularBlockEntity.thirdYCartesian
        )

        self.init(id: id, boardId: boardId, firstPoint: firstPoint, secondPoint: secondPoint, thirdPoint: thirdPoint)
    }
}
