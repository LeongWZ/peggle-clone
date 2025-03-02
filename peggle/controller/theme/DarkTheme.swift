import UIKit

final class DarkTheme: Theme {
    private static let singleton = DarkTheme()

    let style: UIUserInterfaceStyle = .dark

    private init() {
    }

    static func getInstance() -> DarkTheme {
        singleton
    }
}
