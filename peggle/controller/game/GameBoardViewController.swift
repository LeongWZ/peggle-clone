import UIKit

class GameBoardViewController: UIViewController, IGameManager {
    var displayLink: CADisplayLink?
    var isLoopRunning: Bool = false
    let gameEngine = GameEngine()

    private let levelQuery: LevelQuery? = CoreDataLevelQuery()
    private var lastUpdateTime: CFTimeInterval = 0
    private var gameStateObservers: [GameStateObserver] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCannon()
        loadBoard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setGameBoundary(bounds: view.bounds)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink?.invalidate()
    }

    @objc func gameLoop(displayLink: CADisplayLink) {
        guard lastUpdateTime > 0 else {
            lastUpdateTime = displayLink.timestamp
            return
        }

        let deltaTime = displayLink.timestamp - lastUpdateTime
        lastUpdateTime = displayLink.timestamp

        refreshGame(deltaTime: deltaTime)
    }

    func reloadBoard() {
        clearBoard()
        loadBoard()
    }

    func notifyGameStateObservers(_ gameState: GameState) {
        gameStateObservers.removeAll(where: { observer in
            !observer.observe(gameState)
        })
    }

    func showGameEndAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
        })
        present(alert, animated: true, completion: nil)
    }

    func setLevel(_ levelId: UUID) {
        let emptyLevel = LevelModel(id: levelId, name: "")

        let boundaryWidth = view.bounds.width
        let boundaryHeight = view.bounds.height

        let level = levelQuery?
            .fetchByIdOrElseWithPreloadedLevels(
                levelId,
                emptyLevel,
                boundaryWidth: boundaryWidth,
                boundaryHeight: boundaryHeight
            ) ?? emptyLevel

        gameEngine.reset(board: level.board)
        reloadBoard()
    }

    func setLevel(_ level: LevelModel) {
        gameEngine.reset(board: level.board)
        reloadBoard()
    }

    private func loadBoard() {
        let gameState = gameEngine.snapshot()
        loadPegs(gameState)
        loadBucket(gameState)
        loadTriangularBlocks(gameState)
    }

    private func clearBoard() {
        clearPegs()
        clearBucket()
        clearTriangularBlocks()
        clearBall()
        gameStateObservers.removeAll()
    }

    private func loadPegs(_ gameState: GameState) {
        for peg in gameState.pegs.values {
            peg.render(renderer: self)
        }
    }

    private func loadBucket(_ gameState: GameState) {
        let bucketView = BucketView(bucket: gameState.bucket)
        view.addSubview(bucketView)
        gameStateObservers.append(bucketView)
    }

    private func loadTriangularBlocks(_ gameState: GameState) {
        for block in gameState.triangularBlocks {
            block.render(renderer: self)
        }
    }

    private func loadCannon() {
        let cannonView = CannonView(gameLaunchBallDelegate: self)
        view.addSubview(cannonView)
        cannonView.center = CGPoint(x: view.bounds.midX, y: cannonView.bounds.height / 2)
    }

    private func clearPegs() {
        view.subviews
            .compactMap { subview in subview as? PegView }
            .forEach { pegView in pegView.removeFromSuperview() }
    }

    private func clearTriangularBlocks() {
        view.subviews
            .compactMap { subview in subview as? TriangularBlockView }
            .forEach { triangleBlockView in triangleBlockView.removeFromSuperview() }
    }

    private func clearBucket() {
        view.subviews
            .compactMap { subview in subview as? BucketView }
            .forEach { bucketView in bucketView.removeFromSuperview() }
    }

    private func clearBall() {
        view.subviews
            .compactMap { subview in subview as? BallView }
            .forEach { ballView in ballView.removeFromSuperview() }
    }
}

extension GameBoardViewController: PegRenderer {

    func render(peg: NormalPegModel) {
        let pegView = BluePegView(peg: peg, deletePegDelegate: nil, updatePegDelegate: nil, hasGestures: false)
        view.addSubview(pegView)
        gameStateObservers.append(pegView)
    }

    func render(peg: PointPegModel) {
        let pegView = OrangePegView(peg: peg, deletePegDelegate: nil, updatePegDelegate: nil, hasGestures: false)
        view.addSubview(pegView)
        gameStateObservers.append(pegView)
    }

    func render(peg: PowerUpPegModel) {
        let pegView = GreenPegView(peg: peg, deletePegDelegate: nil, updatePegDelegate: nil, hasGestures: false)
        view.addSubview(pegView)
        gameStateObservers.append(pegView)
    }
}

extension GameBoardViewController: BlockRenderer {
    func render(block: TriangularBlockModel) {
        let blockView = TriangularBlockView(
            triangularBlock: block,
            deleteTriangularBlockDelegate: nil,
            updateTriangularBlockDelegate: nil,
            hasGestures: false
        )
        view.addSubview(blockView)
    }
}

extension GameBoardViewController: GameLaunchBallDelegate {

    func launchBall(from source: CGPoint, to target: CGPoint) {
        guard isLoopRunning else {
            return
        }

        let previousGameState = gameEngine.snapshot()

        let gameState = gameEngine.launchBall(
            from: Position(xCartesian: source.x, yCartesian: source.y),
            to: Position(xCartesian: target.x, yCartesian: target.y)
        )

        guard let ball = gameState.activeBall, ball != previousGameState.activeBall else {
            return
        }

        let ballView = BallView(ball: ball)
        view.addSubview(ballView)
        gameStateObservers.append(ballView)

        notifyGameStateObservers(gameState)
    }

}
