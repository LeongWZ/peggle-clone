import UIKit

final class BluePegView: PegView {
    private static let ImageName = "peg-blue"
    private static let HighlightedImageName = "peg-blue-glow"

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(peg: PegModelable, deletePegDelegate: LevelDesignerDeletePegDelegate?,
         updatePegDelegate: LevelDesignerUpdatePegDelegate?, hasGestures: Bool) {
        super.init(
            peg: peg,
            image: UIImage(named: BluePegView.ImageName),
            highlightedImage: UIImage(named: BluePegView.HighlightedImageName),
            deletePegDelegate: deletePegDelegate,
            updatePegDelegate: updatePegDelegate,
            hasGestures: hasGestures
        )
    }
}
