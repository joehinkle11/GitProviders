//
//  DisableModalDismiss.swift
//  appmaker
//
//  Created by Joseph Hinkle on 8/25/20.
//

import SwiftUI

struct DisableModalDismiss: ViewModifier {
    let disabled: Bool
    func body(content: Content) -> some View {
        disableModalDismiss()
        return AnyView(content)
    }

    func disableModalDismiss() {
        guard let visibleController = UIApplication.shared.visibleViewController() else { return }
        visibleController.isModalInPresentation = disabled
    }
}


extension UIApplication {

    func visibleViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return nil }
        guard let rootViewController = window.rootViewController else { return nil }
        return UIApplication.getVisibleViewControllerFrom(vc: rootViewController)
    }
    private static func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
            let visibleController = navigationController.visibleViewController  {
            return UIApplication.getVisibleViewControllerFrom( vc: visibleController )
        } else if let tabBarController = vc as? UITabBarController,
            let selectedTabController = tabBarController.selectedViewController {
            return UIApplication.getVisibleViewControllerFrom(vc: selectedTabController )
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIApplication.getVisibleViewControllerFrom(vc: presentedViewController)
            } else {
                return vc
            }
        }
    }
    
    func firstUiSplitViewController() -> UISplitViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return nil }
        guard let rootViewController = window.rootViewController else { return nil }
        return firstUiSplitViewControllerHelper(rootViewController)
    }
    
    private func firstUiSplitViewControllerHelper(_ view: UIViewController) -> UISplitViewController? {
        if let uiSplitViewController = view as? UISplitViewController {
            return uiSplitViewController
        } else {
            for subview in view.children {
                if let uiSplitViewController = firstUiSplitViewControllerHelper(subview) {
                    return uiSplitViewController
                }
            }
            return nil
        }
    }
}
