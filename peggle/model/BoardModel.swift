import Foundation

/// A model representing a board in the game.
/// Each board has a unique identifier, an optional level identifier, and contains normal and point pegs.
struct BoardModel {
    let id: UUID
    let levelId: UUID?
    let normalPegs: [NormalPegModel]
    let pointPegs: [PointPegModel]
    let powerUpPegs: [PowerUpPegModel]
    let triangularBlocks: [TriangularBlockModel]

    /// A computed property that returns all pegs on the board.
    var allPegs: [PegModelable] {
        normalPegs + pointPegs + powerUpPegs
    }

    /// Resets the board by removing all pegs.
    /// - Returns: A new `BoardModel` instance with no pegs.
    func reset() -> BoardModel {
        BoardModel(id: id, levelId: levelId, normalPegs: [], pointPegs: [], powerUpPegs: [],
                   triangularBlocks: [])
    }

    /// Adds a normal peg to the board.
    /// - Parameter peg: The normal peg to be added.
    /// - Returns: The updated board with the normal peg added if it can be added. Otherwise, the original board.
    func addPeg(peg: NormalPegModel) -> BoardModel {
        if !canAddPeg(peg: peg) {
            return self
        }

        return BoardModel(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs + [peg],
            pointPegs: pointPegs,
            powerUpPegs: powerUpPegs,
            triangularBlocks: triangularBlocks
        )
    }

    /// Adds a point peg to the board.
    /// - Parameter peg: The point peg to be added.
    /// - Returns: The updated board with the point peg added if it can be added. Otherwise, the original board.
    func addPeg(peg: PointPegModel) -> BoardModel {
        if !canAddPeg(peg: peg) {
            return self
        }

        return BoardModel(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs,
            pointPegs: pointPegs + [peg],
            powerUpPegs: powerUpPegs,
            triangularBlocks: triangularBlocks
        )
    }

    func addPeg(peg: PowerUpPegModel) -> BoardModel {
        if !canAddPeg(peg: peg) {
            return self
        }

        return BoardModel(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs,
            pointPegs: pointPegs,
            powerUpPegs: powerUpPegs + [peg],
            triangularBlocks: triangularBlocks
        )
    }

    /// Removes a normal peg from the board.
    /// - Parameter target: The normal peg to be removed.
    /// - Returns: The updated board with the normal peg removed.
    func removePeg(peg target: NormalPegModel) -> BoardModel {
        BoardModel(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs.filter { peg in peg != target },
            pointPegs: pointPegs,
            powerUpPegs: powerUpPegs,
            triangularBlocks: triangularBlocks
        )
    }

    /// Removes a point peg from the board.
    /// - Parameter target: The point peg to be removed.
    /// - Returns: The updated board with the point peg removed.
    func removePeg(peg target: PointPegModel) -> BoardModel {
        BoardModel(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs,
            pointPegs: pointPegs.filter { peg in peg != target },
            powerUpPegs: powerUpPegs,
            triangularBlocks: triangularBlocks
        )
    }

    func removePeg(peg target: PowerUpPegModel) -> BoardModel {
        BoardModel(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs,
            pointPegs: pointPegs,
            powerUpPegs: powerUpPegs.filter { peg in peg != target },
            triangularBlocks: triangularBlocks
        )
    }

    func removePegs(_ predicate: (_ peg: PegModelable) -> Bool) -> BoardModel {
        BoardModel(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs.filter { peg in !predicate(peg) },
            pointPegs: pointPegs.filter { peg in !predicate(peg) },
            powerUpPegs: powerUpPegs.filter { peg in !predicate(peg) },
            triangularBlocks: triangularBlocks
        )
    }

    func movePeg(pegToMove: NormalPegModel, movedPeg: NormalPegModel) -> (BoardModel, NormalPegModel) {
        if !canMovePeg(pegToMove: pegToMove, movedPeg: movedPeg) {
            return (self, pegToMove)
        }

        let newBoard = BoardModel(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs.map { peg in peg == pegToMove ? movedPeg : peg },
            pointPegs: pointPegs,
            powerUpPegs: powerUpPegs,
            triangularBlocks: triangularBlocks
        )

        return (newBoard, movedPeg)
    }

    func movePeg(pegToMove: PointPegModel, movedPeg: PointPegModel) -> (BoardModel, PointPegModel) {
        if !canMovePeg(pegToMove: pegToMove, movedPeg: movedPeg) {
            return (self, pegToMove)
        }

        let newBoard = BoardModel(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs,
            pointPegs: pointPegs.map { peg in peg == pegToMove ? movedPeg : peg },
            powerUpPegs: powerUpPegs,
            triangularBlocks: triangularBlocks
        )

        return (newBoard, movedPeg)
    }

    func movePeg(pegToMove: PowerUpPegModel, movedPeg: PowerUpPegModel) -> (BoardModel, PowerUpPegModel) {
        if !canMovePeg(pegToMove: pegToMove, movedPeg: movedPeg) {
            return (self, pegToMove)
        }

        let newBoard = BoardModel(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs,
            pointPegs: pointPegs,
            powerUpPegs: powerUpPegs.map { peg in peg == pegToMove ? movedPeg : peg },
            triangularBlocks: triangularBlocks
        )

        return (newBoard, movedPeg)
    }

    func addTriangularBlock(block: TriangularBlockModel) -> BoardModel {
        if !canAddTriangularBlock(block: block) {
            return self
        }

        return BoardModel(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs,
            pointPegs: pointPegs,
            powerUpPegs: powerUpPegs,
            triangularBlocks: triangularBlocks + [block]
        )
    }

    func removeTriangularBlock(block target: TriangularBlockModel) -> BoardModel {
        BoardModel(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs,
            pointPegs: pointPegs,
            powerUpPegs: powerUpPegs,
            triangularBlocks: triangularBlocks.filter { block in block != target }
        )
    }

    func moveTriangularBlock(blockToMove: TriangularBlockModel,
                             movedBlock: TriangularBlockModel) -> (BoardModel, TriangularBlockModel) {
        if !canMoveTriangularBlock(blockToMove: blockToMove, movedBlock: movedBlock) {
            return (self, blockToMove)
        }

        let newBoard = BoardModel(
            id: id,
            levelId: levelId,
            normalPegs: normalPegs,
            pointPegs: pointPegs,
            powerUpPegs: powerUpPegs,
            triangularBlocks: triangularBlocks.map { block in block == blockToMove ? movedBlock : block }
        )

        return (newBoard, movedBlock)
    }

    private func canAddPeg(peg pegToAdd: PegModelable) -> Bool {
        for peg in allPegs where peg.willCollide(with: pegToAdd) {
            return false
        }

        for block in triangularBlocks where block.willCollide(with: pegToAdd) {
            return false
        }

        return true
    }

    private func canMovePeg(pegToMove: PegModelable, movedPeg: PegModelable) -> Bool {
        for peg in allPegs where peg.center != pegToMove.center && peg.willCollide(with: movedPeg) {
            return false
        }

        for block in triangularBlocks where block.willCollide(with: movedPeg) {
            return false
        }

        return true
    }

    private func canAddTriangularBlock(block blockToAdd: TriangularBlockModel) -> Bool {
        for block in triangularBlocks where blockToAdd.willCollide(with: block) {
            return false
        }

        for peg in allPegs where blockToAdd.willCollide(with: peg) {
            return false
        }

        return true
    }

    private func canMoveTriangularBlock(blockToMove: TriangularBlockModel, movedBlock: TriangularBlockModel) -> Bool {
        for block in triangularBlocks where block.centroid != blockToMove.centroid
            && movedBlock.willCollide(with: block) {
            return false
        }

        for peg in allPegs where movedBlock.willCollide(with: peg) {
            return false
        }

        return true
    }
}

// MARK: Equatable & Hashable
extension BoardModel: Equatable, Hashable {
}
