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
public struct Settings {
    
    @ObservableState
    public struct State: Equatable {
        
        @Shared(.settings) var settings
        @Shared(.appStorage("refreshRate")) var refreshRate: Double?
        
        init() {
        }
    }
    
    public enum Action: Equatable, ViewAction, BindableAction {
        
        case view(View)
        case binding(BindingAction<State>)
        
        public enum View: Equatable {
            case task
        }
    }
    
    public var body: some ReducerOf<Self> {
        CombineReducers {
            BindingReducer()
            
            Reduce { state, action in
                switch action {
                case .view(.task):
                    return .none
                case .binding:
                    return .none
                }
            }
        }
        .onChange(of: \.settings.general.refreshRate) { oldValue, newValue in
            Reduce { state, _ in
                state.refreshRate = newValue.timeInterval
                return .none
            }
        }
    }
    
    public init() {}
}

struct SettingsView: View {
    @Bindable var store: StoreOf<Settings>
    
    var body: some View {
        NavigationStack {
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
                
                NavigationLink("Second view") {
                    SecondView()
                }
                NavigationLink("Third view") {
                    ThirdView(store: .init(initialState: .init()) { Third() })
                }
            }
        }
    }
}

struct SecondView: View {
    @SharedReader(.settings) var settings
    @SharedReader(.appStorage("refreshRate")) var refreshRate: Double?
    var body: some View {
        Text(settings.general.refreshRate.timeInterval.debugDescription)
        Text("\(settings.general.openingTab)")
        
        Text(refreshRate.debugDescription)
        
        Text(settings.developer.isMapOnlyModeEnabled.description)
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
