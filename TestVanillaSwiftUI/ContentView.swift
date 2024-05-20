//
//  ContentView.swift
//  TestVanillaSwiftUI
//
//  Created by Roberto Casula on 20/05/24.
//

import SwiftUI

struct Second: View {
    @AppStorage("openingTab") var openingTab: Tab = .map
    
    var body: some View {
        Text("\(openingTab)")
    }
}

struct Third: View {
    @AppStorage("openingTab") var openingTab: Tab = .map
    
    var body: some View {
        Picker(selection: $openingTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Text("\(tab)")
                    .tag(tab)
            }
        } label: {
            Text("Opening tab")
        }
    }
}

struct Settings: View {
    
    @AppStorage("openingTab") var openingTab: Tab = .map
    
    var body: some View {
        NavigationStack {
            Form {
                Picker(selection: $openingTab) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Text("\(tab)")
                            .tag(tab)
                    }
                } label: {
                    Text("Opening tab")
                }
                
                NavigationLink {
                    Second()
                } label: {
                    Text("Second view")
                }
                NavigationLink {
                    Third()
                } label: {
                    Text("Third view")
                }
            }
        }
    }
}

#Preview("Settings") {
    Settings()
}

struct Child: View {
    let title: String
    
    @State var isSettingsShown = false
    
    var body: some View {
        VStack {
            Text(title)
            
            Button {
                isSettingsShown = true
            } label: {
                Text("Settings")
            }
        }
        .sheet(isPresented: $isSettingsShown) {
            Settings()
        }
    }
}

#Preview("Child") {
    Child(title: "Test")
}

enum Tab: Int, CaseIterable {
    case train
    case map
    case bus
}

struct Home: View {
    
    @State var selectedTab: Tab = .map
    
    @AppStorage("openingTab") var openingTab: Tab = .map
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Child(title: "\(tab)")
                    .tabItem { Text("\(tab)") }
                    .tag(tab)
            }
        }
        .task {
            self.selectedTab = openingTab
        }
    }
}

#Preview("Home") {
    Home()
}

struct ContentView: View {
    var body: some View {
        Home()
    }
}

#Preview {
    ContentView()
        .defaultAppStorage(.init(suiteName: "test.suite")!)
}
