//
//  TCASharedState_ShowcaseApp.swift
//  TCASharedState Showcase
//
//  Created by Roberto Casula on 20/05/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct TCASharedState_ShowcaseApp: App {
    let store = Store(initialState: .init()) {
        Home()
    } withDependencies: {
        $0.defaultAppStorage = UserDefaults(suiteName: "group.dev.casula.TCA.SharedStateShowcase")!
//        $0.defaultAppStorage = .standard
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
