import UIKit

final class LightTheme: Theme {
    private static let singleton = LightTheme()

    let style: UIUserInterfaceStyle = .light

    private init() {
    }

    static func getInstance() -> LightTheme {
        singleton
    }
}
