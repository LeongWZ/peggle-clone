protocol LevelDesignerDeletePegDelegate: AnyObject {

    /// - Returns: `true` if peg has been deleted, otherwise `false`
    func deletePegOnTap(peg: PegModelable) -> Bool

    func deletePegOnLongPress(peg: PegModelable)
}
