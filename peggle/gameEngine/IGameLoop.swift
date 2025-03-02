import QuartzCore

@objc
protocol IGameLoop {
    var displayLink: CADisplayLink? { get set }

    var isLoopRunning: Bool { get set }

    @objc func gameLoop(displayLink: CADisplayLink)
}

extension IGameLoop {
    func startLoop() {
        displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
        displayLink?.add(to: .current, forMode: .common)
        isLoopRunning = true
    }

    func stopLoop() {
        displayLink?.isPaused = true
        displayLink?.invalidate()
        displayLink = nil
        isLoopRunning = false
    }
}
