//
//  Gold_Golf_TurnomentsApp.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 2/2/26.
//

import SwiftUI
import FirebaseCore
import ClerkKit
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      print("This ran")
    return true
  }
    
}

@main
struct Gold_Golf_TurnomentsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        Clerk.configure(publishableKey: "pk_test_YWNlLXNocmV3LTYwLmNsZXJrLmFjY291bnRzLmRldiQ")
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(Clerk.shared)
        }
//        WindowGroup {
//            AuthView()
//        }
    }
}
