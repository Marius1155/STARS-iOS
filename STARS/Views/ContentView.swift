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
            view: SearchAppleMusicAlbumsView(),
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

#Preview {
    ContentView()
}

