import Foundation

struct PreloadedLevelsHelper {
    static func isLevelPreloaded(_ level: LevelModel) -> Bool {
        preloadedLevels.map { $0.id }.contains(level.id)
    }

    static func getPreloadedLevels(boundaryWidth: Double, boundaryHeight: Double) -> [LevelModel] {
        preloadedLevels.map { normalizedLevel in
            scaleNormalizedLevel(normalizedLevel, width: boundaryWidth, height: boundaryHeight)
        }
    }

    private static func scaleNormalizedLevel(_ level: LevelModel, width: Double, height: Double) -> LevelModel {
        let boardId = level.board.id

        func scalePosition(_ position: Position) -> Position {
            Position(xCartesian: position.xCartesian * width, yCartesian: position.yCartesian * height)
        }

        let normalPegs = level.board.normalPegs.map {
            NormalPegModel.ofDefault(id: $0.id, boardId: boardId, center: scalePosition($0.center))
        }

        let pointPegs = level.board.pointPegs.map {
            PointPegModel.ofDefault(id: $0.id, boardId: boardId, center: scalePosition($0.center))
        }

        let powerUpPegs = level.board.powerUpPegs.map {
            PowerUpPegModel.ofDefault(id: $0.id, boardId: boardId, center: scalePosition($0.center))
        }

        let triangularBlocks = level.board.triangularBlocks.map {
            TriangularBlockModel.ofDefault(centroid: scalePosition($0.centroid), boardId: boardId)
        }

        let scaledBoard = BoardModel(
            id: boardId,
            levelId: level.board.levelId,
            normalPegs: normalPegs,
            pointPegs: pointPegs,
            powerUpPegs: powerUpPegs,
            triangularBlocks: triangularBlocks
        )

        return LevelModel(id: level.id, name: level.name, board: scaledBoard)
    }

    private static var preloadedLevels: [LevelModel] {
        [PreloadedLevelAlpha, PreloadedLevelBeta, PreloadedLevelCharlie]
    }

    private static let PreloadedLevelAlpha: LevelModel = {
        let boardId = UUID()
        let normalPegs = [
            NormalPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.1, yCartesian: 0.1)),
            NormalPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.9, yCartesian: 0.1)),
            NormalPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.1, yCartesian: 0.9)),
            NormalPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.9, yCartesian: 0.9))
        ]
        let pointPegs = [
            PointPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.5, yCartesian: 0.5))
        ]
        let powerUpPegs = [
            PowerUpPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.5, yCartesian: 0.1))
        ]
        let triangularBlocks = [
            TriangularBlockModel.ofDefault(centroid: Position(xCartesian: 0.5, yCartesian: 0.8), boardId: boardId)
        ]
        let board = BoardModel(id: boardId, levelId: nil, normalPegs: normalPegs, pointPegs: pointPegs,
                               powerUpPegs: powerUpPegs, triangularBlocks: triangularBlocks)
        return LevelModel(id: UUID(), name: "Alpha", board: board)
    }()

    private static let PreloadedLevelBeta: LevelModel = {
        let boardId = UUID()
        let normalPegs = [
            NormalPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.2, yCartesian: 0.2)),
            NormalPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.8, yCartesian: 0.2)),
            NormalPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.2, yCartesian: 0.8)),
            NormalPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.8, yCartesian: 0.8))
        ]
        let pointPegs = [
            PointPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.5, yCartesian: 0.5))
        ]
        let powerUpPegs = [
            PowerUpPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.5, yCartesian: 0.2))
        ]
        let triangularBlocks = [
            TriangularBlockModel.ofDefault(centroid: Position(xCartesian: 0.5, yCartesian: 0.7), boardId: boardId)
        ]
        let board = BoardModel(id: boardId, levelId: nil, normalPegs: normalPegs, pointPegs: pointPegs,
                               powerUpPegs: powerUpPegs, triangularBlocks: triangularBlocks)
        return LevelModel(id: UUID(), name: "Beta", board: board)
    }()

    static let PreloadedLevelCharlie: LevelModel = {
        let boardId = UUID()
        let normalPegs = [
            NormalPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.3, yCartesian: 0.3)),
            NormalPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.7, yCartesian: 0.3)),
            NormalPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.3, yCartesian: 0.7)),
            NormalPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.7, yCartesian: 0.7))
        ]
        let pointPegs = [
            PointPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.5, yCartesian: 0.5))
        ]
        let powerUpPegs = [
            PowerUpPegModel.ofDefault(id: UUID(), boardId: boardId, center: Position(xCartesian: 0.5, yCartesian: 0.3))
        ]
        let triangularBlocks = [
            TriangularBlockModel.ofDefault(centroid: Position(xCartesian: 0.3, yCartesian: 0.5), boardId: boardId)
        ]
        let board = BoardModel(id: boardId, levelId: nil, normalPegs: normalPegs, pointPegs: pointPegs,
                               powerUpPegs: powerUpPegs, triangularBlocks: triangularBlocks)
        return LevelModel(id: UUID(), name: "Charlie", board: board)
    }()
}
