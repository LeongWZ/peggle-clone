import UIKit

protocol LevelDesignerUpdateTriangularBlockDelegate: AnyObject {
    var shouldRotateBlockOnDrag: Bool { get }

    func moveTriangularBlockCenter(triangularBlock: TriangularBlockModel, to point: CGPoint) -> TriangularBlockModel

    func moveTriangularBlockFirstPoint(triangularBlock: TriangularBlockModel, to point: CGPoint) -> TriangularBlockModel

    func moveTriangularBlockSecondPoint(triangularBlock: TriangularBlockModel,
                                        to point: CGPoint) -> TriangularBlockModel

    func moveTriangularBlockThirdPoint(triangularBlock: TriangularBlockModel, to point: CGPoint) -> TriangularBlockModel

    func rotateTriangularBlock(triangularBlock: TriangularBlockModel, by angleRadians: CGFloat) -> TriangularBlockModel
}
