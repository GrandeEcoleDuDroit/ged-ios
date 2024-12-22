import UIKit

extension UINavigationController {
  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
      navigationBar.topItem?.backButtonDisplayMode = .minimal
  }
}
