protocol GameResumeDelegate: AnyObject {
    var isGameStateOngoing: Bool { get }

    func resumeGame()
}
