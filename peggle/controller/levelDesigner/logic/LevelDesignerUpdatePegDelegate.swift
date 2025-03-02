import UIKit

protocol LevelDesignerUpdatePegDelegate: AnyObject {
    var shouldRotatePegOnDrag: Bool { get }

    func movePeg(peg: PegModelable, to point: CGPoint) -> PegModelable

    func rotatePeg(peg: PegModelable, by angleRadians: CGFloat) -> PegModelable

    func scalePeg(peg: PegModelable, by scale: Double) -> PegModelable
}
