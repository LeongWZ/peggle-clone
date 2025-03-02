import UIKit

final class ThemeManager {
    private static let singleton = ThemeManager()

    private var theme: Theme?

    private init() {
    }

    static func getInstance() -> ThemeManager {
        singleton
    }

    func hasTheme(_ theme: Theme) -> Bool {
        self.theme === theme
    }

    func activate(theme: DarkTheme, window: UIWindow?) {
        self.theme = theme
        window?.overrideUserInterfaceStyle = theme.style
    }

    func activate(theme: LightTheme, window: UIWindow?) {
        self.theme = theme
        window?.overrideUserInterfaceStyle = theme.style
    }
}
