//
//  TestVanillaSwiftUIApp.swift
//  TestVanillaSwiftUI
//
//  Created by Roberto Casula on 20/05/24.
//

import SwiftUI

@main
struct TestVanillaSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .defaultAppStorage(.init(suiteName: "group.test.suite")!)
        }
    }
}
