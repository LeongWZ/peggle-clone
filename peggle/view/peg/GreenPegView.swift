import UIKit

final class GreenPegView: PegView {
    private static let ImageName = "peg-green"
    private static let HighlightedImageName = "peg-green-glow"

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(peg: PegModelable, deletePegDelegate: LevelDesignerDeletePegDelegate?,
         updatePegDelegate: LevelDesignerUpdatePegDelegate?, hasGestures: Bool) {
        super.init(
            peg: peg,
            image: UIImage(named: GreenPegView.ImageName),
            highlightedImage: UIImage(named: GreenPegView.HighlightedImageName),
            deletePegDelegate: deletePegDelegate,
            updatePegDelegate: updatePegDelegate,
            hasGestures: hasGestures
        )
    }
}
