protocol LevelDesignerDeleteTriangularBlockDelegate: AnyObject {

    func deleteTriangularBlockOnTap(triangularBlock: TriangularBlockModel) -> Bool

    func deleteTriangularBlockOnLongPress(triangularBlock: TriangularBlockModel)
}
