import UIKit

final class OrangePegView: PegView {
    private static let ImageName = "peg-orange"
    private static let HighlightedImageName = "peg-orange-glow"

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(peg: PegModelable, deletePegDelegate: LevelDesignerDeletePegDelegate?,
         updatePegDelegate: LevelDesignerUpdatePegDelegate?, hasGestures: Bool) {
        super.init(
            peg: peg,
            image: UIImage(named: OrangePegView.ImageName),
            highlightedImage: UIImage(named: OrangePegView.HighlightedImageName),
            deletePegDelegate: deletePegDelegate,
            updatePegDelegate: updatePegDelegate,
            hasGestures: hasGestures
        )
    }
}
