//
//  Test2.swift
//  Test
//
//  Created by Roberto Casula on 07/05/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct Settings {
    
    @ObservableState
    public struct State: Equatable {
        
        @Shared(.settings) var settings
        @Shared(.appStorage("refreshRate")) var refreshRate: Double?
        
        var third: Third.State = .init()
        
        var path: StackState<Path.State> = StackState()
        
        init() {
        }
    }
    
    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        case third(Third)
    }
    
    enum Action: Equatable, ViewAction, BindableAction {
        case third(Third.Action)
        case view(View)
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        
        public enum View: Equatable {
            case task
        }
    }
    
    var body: some ReducerOf<Self> {
        CombineReducers {
            BindingReducer()
            
            Reduce { state, action in
                switch action {
                case .third:
                    return .none
                case .view(.task):
                    return .none
                case .binding:
                    return .none
                case .path:
                    return .none
                }
            }
        }
        .forEach(\.path, action: \.path)
        .onChange(of: \.settings.general.refreshRate) { oldValue, newValue in
            Reduce { state, _ in
                state.refreshRate = newValue.timeInterval
                return .none
            }
        }
        
        Scope(state: \.third, action: \.third) {
            Third()
        }
    }
    
    public init() {}
}

struct SettingsView: View {
    @Bindable var store: StoreOf<Settings>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Form {
                Picker(selection: $store.settings.general.refreshRate) {
                    ForEach(UserSettings.General.RealtimeRefreshRate.allCases, id: \.self) { refreshRate in
                        Text(refreshRate.timeInterval.debugDescription)
                            .tag(refreshRate)
                    }
                } label: {
                    Text("Refresh rate")
                }
                Picker(selection: $store.settings.general.openingTab) {
                    ForEach(UserSettings.General.OpeningTab.allCases, id: \.self) { tab in
                        Text("\(tab)")
                            .tag(tab)
                    }
                } label: {
                    Text("Opening tab")
                }
                
                Text(store.refreshRate.debugDescription)
                
                Toggle(isOn: $store.settings.developer.isMapOnlyModeEnabled) {
                    Text("[Settings] Map only")
                }
                
                NavigationLink("Third view") {
                    ThirdView(store: store.scope(state: \.third, action: \.third))
                }
                NavigationLink(state: Settings.Path.State.third(.init())) {
                    Text("Third view with navigation state")
                }
            }
        } destination: { store in
            switch store.case {
            case .third(let store):
                ThirdView(store: store)
            }
        }
    }
}

@Reducer
public struct Third {
    
    @ObservableState
    public struct State: Equatable {
        
        @Shared(.settings) var settings
        @Shared(.appStorage("refreshRate")) var refreshRate: Double?
    }
    
    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
    }
    
    public var body: some ReducerOf<Self> {
        CombineReducers {
            BindingReducer()
            
            Reduce { state, action in
                switch action {
                case .binding:
                    return .none
                }
            }
        }
    }
    
    public init() {}
}

struct ThirdView: View {
    @Bindable var store: StoreOf<Third>
    
    var body: some View {
        Text(store.settings.general.refreshRate.timeInterval.debugDescription)
        Text(store.refreshRate.debugDescription)
        
        Text(store.settings.developer.isMapOnlyModeEnabled.description)
        
        Toggle(isOn: $store.settings.developer.isMapOnlyModeEnabled) {
            Text("[Settings] Map only")
        }
        
        Picker(selection: $store.settings.general.openingTab) {
            ForEach(UserSettings.General.OpeningTab.allCases, id: \.self) { tab in
                Text("\(tab)")
                    .tag(tab)
            }
        } label: {
            Text("Opening tab")
        }
    }
}
