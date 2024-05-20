//
//  ContentView.swift
//  TCASharedState Showcase
//
//  Created by Roberto Casula on 20/05/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct Child {
    
    @ObservableState
    public struct State: Equatable {
        let title: String
        
        @Presents var destination: Destination.State?
        
        init(title: String, destination: Destination.State? = nil) {
            self.title = title
            self.destination = destination
        }
    }
    
    @Reducer(state: .equatable, action: .equatable)
    public enum Destination {
        case settings(Settings)
    }
    
    public enum Action: Equatable, ViewAction, BindableAction {
    
        case view(View)
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        
        public enum View: Equatable {
            case task
            case showSettings
        }
    }
    
    public var body: some ReducerOf<Self> {
        CombineReducers {
            BindingReducer()
            
            Reduce { state, action in
                switch action {
                case .view(.task):
                    return .none
                case .view(.showSettings):
                    state.destination = .settings(.init())
                    return .none
                case .binding:
                    return .none
                case .destination:
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
    
    public init() {}
}

@ViewAction(for: Child.self)
struct ChildView: View {
    @Bindable var store: StoreOf<Child>
    
    var body: some View {
        VStack {
            Button {
                send(.showSettings)
            } label: {
                Text("settings")
            }
            Text(store.title)
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.settings,
                action: \.destination.settings
            )
        ) { store in
            SettingsView(store: store)
        }
    }
}

#Preview {
    ChildView(
        store: .init(
            initialState: .init(title: "Test child view")
        ) {
            Child()
        } withDependencies: {
            $0.defaultAppStorage = .standard
        }
    )
}

extension UserSettings.General.OpeningTab {
    var tab: Home.State.Tab {
        switch self {
        case .bus: .bus
        case .train: .train
        case .map: .map
        }
    }
}

@Reducer
public struct Home {
    
    @ObservableState
    public struct State: Equatable {
        
        enum Tab: Int, CaseIterable {
            case train
            case map
            case bus
            
            var title: String {
                switch self {
                case .bus: "bus"
                case .train: "train"
                case .map: "map"
                }
            }
            
            @ViewBuilder
            func view(for store: StoreOf<Home>) -> some View {
                switch self {
                case .bus:
                    ChildView(store: store.scope(state: \.bus, action: \.bus))
                case .map:
                    ChildView(store: store.scope(state: \.map, action: \.map))
                case .train:
                    ChildView(store: store.scope(state: \.train, action: \.train))
                }
            }
        }
        
        @SharedReader(.settings) var settings
        @Shared(.appStorage("refreshRate")) var refreshRate: Double?
        
        var selectedTab: Tab = .map
        
        var train = Child.State(title: "Train")
        var map = Child.State(title: "Map")
        var bus = Child.State(title: "Bus")
        
        init() {
            selectedTab = settings.general.openingTab.tab
        }
    }
    
    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case train(Child.Action)
        case map(Child.Action)
        case bus(Child.Action)
    }
    
    public var body: some ReducerOf<Self> {
        CombineReducers {
            BindingReducer()
            
            Reduce { state, action in
                switch action {
                case .binding:
                    return .none
                case .train:
                    return .none
                case .map:
                    return .none
                case .bus:
                    return .none
                }
            }
            
            Scope(state: \.train, action: \.train) {
                Child()
            }
            Scope(state: \.map, action: \.map) {
                Child()
            }
            Scope(state: \.bus, action: \.bus) {
                Child()
            }
        }
    }
    
    public init() {}
}

struct ContentView: View {
    
    @Bindable var store: StoreOf<Home>
    
    var body: some View {
        TabView(selection: $store.selectedTab) {
            ForEach(Home.State.Tab.allCases, id: \.self) { tab in
                tab.view(for: self.store)
                    .tabItem { Text(tab.title) }
                    .tag(tab)
            }
        }
    }
}

#Preview {
    ContentView(
        store: .init(
            initialState: .init()
        ) {
            Home()
        } withDependencies: {
            $0.defaultAppStorage = .standard
        }
    )
}
