//
//  ContentView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 27.08.2024.
//

import SwiftUI
import UIKit

extension Notification.Name {
    static let hideTabBar = Notification.Name("HideTabBar")
    static let showTabBar = Notification.Name("ShowTabBar")
}

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    var dataManager: DataManager?
    private var lastSelectedIndex: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior = .onScrollDown
        }
        
        // Observe keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        // NEW: tab bar show/hide observers
        NotificationCenter.default.addObserver(self, selector: #selector(hideTabBarAnimated), name: .hideTabBar, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showTabBarAnimated), name: .showTabBar, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func hideTabBarAnimated() {
        tabBar.isHidden = true
    }

    @objc private func showTabBarAnimated() {
        tabBar.isHidden = false
    }

    @objc private func keyboardWillShow(notification: Notification) {
        self.tabBar.isHidden = true
    }

    @objc private func keyboardWillHide(notification: Notification) {
        if dataManager?.shouldShowTabBar == true {
            self.tabBar.isHidden = false
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Check if the user tapped the same tab
        if selectedIndex == lastSelectedIndex {
            if let navController = viewController as? UINavigationController {
                print("Returning to root view...")
                navController.popToRootViewController(animated: true)
            } else {
                print("Warning: \(viewController) is not a UINavigationController!")
            }
        }
        lastSelectedIndex = selectedIndex
    }
}

struct UIKitTabView: UIViewControllerRepresentable {
    @AppStorage("userID") var userID: String = ""
    @AppStorage("userIsStaff") var userIsStaff: Bool = false

    func makeUIViewController(context: Context) -> CustomTabBarController {
        let tabBarController = CustomTabBarController()
        tabBarController.dataManager = DataManager.shared
        
        // Create tabs wrapped in UINavigationControllers

        let homeVC = createTab(
            view: HomeView(),
            title: "Home",
            image: "house.fill",
            tag: 1
        )
        
        let messagesVC = createTab(
            view: MessagesView(),
            title: "Messages",
            image: "message.fill",
            tag: 2
        )
        
        let profileVC: UIViewController
        profileVC = createTab(
            view: ProfileView(id: userID),
            title: "Profile",
            image: "person.crop.circle.fill",
            tag: 3
        )
        
        let searchVC = createTab(
            view: SearchView(),
            title: "Search",
            image: "magnifyingglass",
            tag: 4,
            isSearchTab: true
        )
        
        tabBarController.viewControllers = [homeVC, messagesVC, profileVC, searchVC]
        return tabBarController
    }

    func updateUIViewController(_ uiViewController: CustomTabBarController, context: Context) {
        // Nothing to update in this case
    }

    // Helper function to wrap SwiftUI views in UINavigationControllers
    private func createTab<T: View>(view: T, title: String, image: String, tag: Int, isSearchTab: Bool = false) -> UINavigationController {
        let hostingController = UIHostingController(rootView: view)
        if !isSearchTab {
            hostingController.tabBarItem.image = UIImage(systemName: image)
            hostingController.tabBarItem.title = title
            hostingController.tabBarItem.selectedImage = nil
        }
        
        else {
            hostingController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: tag)
            hostingController.tabBarItem.image = UIImage(systemName: image)
            hostingController.tabBarItem.title = title
            hostingController.tabBarItem.selectedImage = nil
            
        }
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
}

// Main ContentView
struct ContentView: View {
    @AppStorage("userIsLoggedIn") var userIsLoggedIn: Bool = false
    @AppStorage("userID") var userID: String = ""
    
    @State private var profilesFetched = false

    var body: some View {
        UIKitTabView()
            .ignoresSafeArea()
    }
}

// MARK: - Tab Bar Hiding Extension
extension View {
    func hideTabBar() -> some View {
        self.background(
            ViewControllerReader { parent in
                // 1. Walk up the chain to find the actual Pushed View Controller.
                // (SwiftUI often nests views in intermediate controllers; we need the one actually on the stack)
                if let navigationController = parent.navigationController,
                   let targetVC = navigationController.viewControllers.last {
                    targetVC.hidesBottomBarWhenPushed = true
                } else {
                    parent.hidesBottomBarWhenPushed = true
                }
            }
        )
    }
}

private struct ViewControllerReader: UIViewControllerRepresentable {
    let customize: (UIViewController) -> Void

    func makeUIViewController(context: Context) -> IntrospectionViewController {
        IntrospectionViewController(customize: customize)
    }

    func updateUIViewController(_ uiViewController: IntrospectionViewController, context: Context) {}
}

private class IntrospectionViewController: UIViewController {
    let customize: (UIViewController) -> Void
    weak var storedTabBarController: UITabBarController?
    var isPopping = false

    init(customize: @escaping (UIViewController) -> Void) {
        self.customize = customize
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if let parent = parent {
            customize(parent)
            self.storedTabBarController = parent.tabBarController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isPopping = false
        
        // Refresh reference
        if let tc = parent?.tabBarController {
            self.storedTabBarController = tc
        }
        
        // EXECUTE THE HIDE
        nukeTabBar()
        
        // Safety: Run again after the run loop to fight Sheet Dismissal animations
        DispatchQueue.main.async { [weak self] in
            self?.nukeTabBar()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // EXECUTE THE HIDE (Fixes Search Bar & Rotation)
        nukeTabBar()
    }

    override func willMove(toParent newParent: UIViewController?) {
        super.willMove(toParent: newParent)
        
        // DETECT POP: If newParent is nil, we are going back to View 1.
        if newParent == nil {
            isPopping = true
            restoreTabBar()
        }
    }
    
    // --- THE NUCLEAR OPTION ---
    // We don't just set isHidden. We set alpha to 0.
    // UIKit loves to flip 'isHidden' back to false during Search/Sheet transitions,
    // but it rarely touches 'alpha'.
    private func nukeTabBar() {
        guard !isPopping else { return } // Don't hide if we are trying to leave!
        
        if let tabBar = storedTabBarController?.tabBar {
            // 1. The Standard Hide
            if !tabBar.isHidden { tabBar.isHidden = true }
            
            // 2. The Alpha Lock (The real fix for persistent issues)
            if tabBar.alpha > 0 { tabBar.alpha = 0 }
            
            // 3. Disable Interaction (Prevents accidental touches if it somehow renders)
            if tabBar.isUserInteractionEnabled { tabBar.isUserInteractionEnabled = false }
        }
    }
    
    private func restoreTabBar() {
        if let tabBar = storedTabBarController?.tabBar {
            // Restore everything for View 1
            tabBar.isHidden = false
            tabBar.alpha = 1.0
            tabBar.isUserInteractionEnabled = true
        }
    }
}
/*extension View {
    func hideTabBar() -> some View {
        self.background(
            ViewControllerReader { parent in
                parent.hidesBottomBarWhenPushed = true
            }
        )
    }
}

private struct ViewControllerReader: UIViewControllerRepresentable {
    let customize: (UIViewController) -> Void

    func makeUIViewController(context: Context) -> IntrospectionViewController {
        IntrospectionViewController(customize: customize)
    }

    func updateUIViewController(_ uiViewController: IntrospectionViewController, context: Context) {}
}

private class IntrospectionViewController: UIViewController {
    let customize: (UIViewController) -> Void
    weak var storedTabBarController: UITabBarController?
    
    // Flag to prevent fighting against the "Back" action
    private var isPopping = false

    init(customize: @escaping (UIViewController) -> Void) {
        self.customize = customize
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if let parent = parent {
            customize(parent)
            self.storedTabBarController = parent.tabBarController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isPopping = false
        
        guard let parent = parent else { return }
        
        // 1. Re-assert the flag (SwiftUI sometimes forgets this on sheet dismiss)
        customize(parent)
        
        // 2. Update reference
        if let tc = parent.tabBarController {
            self.storedTabBarController = tc
        }
        
        // 3. Force Hide (Immediate) - catches standard pushes
        forceHideTabBar()
        
        // 4. Force Hide (Delayed) - CRITICAL FOR SHEET DISMISSAL
        // UIKit often resets the tab bar visibility at the very end of the dismissal animation.
        // We queue this to run on the next graphics cycle to override UIKit's reset.
        DispatchQueue.main.async { [weak self] in
            self?.forceHideTabBar()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Helper to catch rotation or other layout shifts
        forceHideTabBar()
    }

    override func willMove(toParent newParent: UIViewController?) {
        super.willMove(toParent: newParent)
        
        // If newParent is nil, we are being popped (Back button pressed).
        if newParent == nil {
            isPopping = true
            // Restore the bar using our saved reference
            storedTabBarController?.tabBar.isHidden = false
        }
    }

    private func forceHideTabBar() {
        // If we are currently popping (going back), STOP.
        // We do not want to hide the bar if we just explicitly unhid it in 'willMove'.
        if isPopping { return }
        
        // Safety: If the view is already detached, stop.
        if self.parent == nil { return }
        
        // Hide only if currently visible
        if let tabBar = storedTabBarController?.tabBar, !tabBar.isHidden {
            tabBar.isHidden = true
        }
    }
}*/


#Preview {
    ContentView()
}

