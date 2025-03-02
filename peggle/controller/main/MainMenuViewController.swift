import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet private var darkModeSwitch: UISwitch!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        darkModeSwitch.isOn = ThemeManager.getInstance()
            .hasTheme(DarkTheme.getInstance())
    }

    @IBAction private func onDarkModeSwitchChanged(_ sender: UISwitch) {
        let themeManager = ThemeManager.getInstance()

        if sender.isOn {
            themeManager.activate(theme: DarkTheme.getInstance(), window: view.window)
        } else {
            themeManager.activate(theme: LightTheme.getInstance(), window: view.window)
        }
    }
}
