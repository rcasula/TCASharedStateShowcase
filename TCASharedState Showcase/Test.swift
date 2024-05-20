//
//  Test.swift
//  Test
//
//  Created by Roberto Casula on 07/05/24.
//

import ComposableArchitecture
import Foundation

public extension PersistenceReaderKey where Self == PersistenceKeyDefault<CodableAppStorageKey<UserSettings>> {
    static var settings: Self {
        PersistenceKeyDefault(.appStorage("settings"), .init())
    }
}

public struct UserSettings: Equatable, Codable {

    public var general: General
    public var developer: Developer

    public init(
        general: General = .init(),
        developer: Developer = .init()
    ) {
        self.general = general
        self.developer = developer
    }
}

extension UserSettings {
    public struct General: Equatable, Codable {

        public var refreshRate: RealtimeRefreshRate
        public var openingTab: OpeningTab
        public var displayCapolinea: Bool

        public init(
            refreshRate: General.RealtimeRefreshRate = .halfMinute,
            openingTab: OpeningTab = .default,
            displayCapolinea: Bool = true
        ) {
            self.refreshRate = refreshRate
            self.openingTab = openingTab
            self.displayCapolinea = displayCapolinea
        }
    }
}

extension UserSettings {
    public struct Developer: Equatable, Codable {
        public var isMapOnlyModeEnabled: Bool

        public init(
            isMapOnlyModeEnabled: Bool = true
        ) {
            self.isMapOnlyModeEnabled = isMapOnlyModeEnabled
        }
    }
}

extension UserSettings.General {
    public enum RealtimeRefreshRate: Int, CaseIterable, Codable, Equatable {
        case never
        case halfMinute
        case minute

        /// Time interval in seconds
        public var timeInterval: TimeInterval? {
            switch self {
            case .halfMinute: return 30
            case .minute: return 60
            default: return nil
            }
        }
    }
    
    public enum OpeningTab: Int, CaseIterable, Codable, Equatable {
        case bus
        case train
        #if os(iOS)
        case map
        #endif
        
        public static var `default`: Self {
            #if os(iOS)
            return .map
            #else
            return .bus
            #endif
        }
    }
}

extension PersistenceReaderKey {
    public static func appStorage<Value: Codable>(_ key: String) -> Self
    where Self == CodableAppStorageKey<Value> {
        CodableStorageKey(key)
    }
    
    public static func appStorage<Value: Codable>(
        _ keyPath: ReferenceWritableKeyPath<UserDefaults, Data?>
    ) -> Self where Self == CodableAppStorageKeyPathKey<Value> {
        CodableAppStorageKeyPathKey(keyPath)
    }
}

public struct CodableStorageKey<Value: Codable, UnderlyingKey: PersistenceKey>: PersistenceKey where UnderlyingKey.Value == Data? {
    private let appStorageKey: UnderlyingKey
    
    public var id: AnyHashable { appStorageKey.id }
    
    public init(_ key: String) where UnderlyingKey == AppStorageKey<Data?> {
        self.appStorageKey = AppStorageKey(key)
    }
    
    public func load(initialValue: Value?) -> Value? {
        let initialValue = initialValue.flatMap { try? JSONEncoder().encode($0) }
        let value = self.appStorageKey.load(initialValue: initialValue)
        return value?.flatMap { try? JSONDecoder().decode(Value.self, from: $0) }
    }
    
    public func save(_ value: Value) {
        let value = try? JSONEncoder().encode(value)
        self.appStorageKey.save(value)
    }
    
    public func subscribe(
        initialValue: Value?,
        didSet: @Sendable @escaping (_ newValue: Value?) -> Void
    ) -> Shared<Value>.Subscription {
        let initialValue = initialValue.flatMap { try? JSONEncoder().encode($0) }
        let subscription = self.appStorageKey.subscribe(initialValue: initialValue) { newValue in
            let newValue = newValue?.flatMap { try? JSONDecoder().decode(Value.self, from: $0) }
            didSet(newValue)
        }
        return Shared.Subscription(subscription.cancel)
    }
}

public typealias CodableAppStorageKey<Value: Codable> = CodableStorageKey<Value, AppStorageKey<Data?>>

public struct CodableAppStorageKeyPathKey<Value: Codable> {
    private let appStorageKey: AppStorageKeyPathKey<Data?>
    
    public init(_ keyPath: ReferenceWritableKeyPath<UserDefaults, Data?>) {
        self.appStorageKey = AppStorageKeyPathKey(keyPath)
    }
}

extension CodableAppStorageKeyPathKey: PersistenceKey, Hashable {
    
    public func load(initialValue: Value?) -> Value? {
        let initialValue = initialValue.flatMap { try? JSONEncoder().encode($0) }
        let value = self.appStorageKey.load(initialValue: initialValue)
        return value?.flatMap { try? JSONDecoder().decode(Value.self, from: $0) }
    }
    
    public func save(_ value: Value) {
        let value = try? JSONEncoder().encode(value)
        self.appStorageKey.save(value)
    }
    
    public func subscribe(
        initialValue: Value?,
        didSet: @Sendable @escaping (_ newValue: Value?) -> Void
    ) -> Shared<Value>.Subscription {
        let initialValue = initialValue.flatMap { try? JSONEncoder().encode($0) }
        let subscription = self.appStorageKey.subscribe(initialValue: initialValue) { newValue in
            let newValue = newValue?.flatMap { try? JSONDecoder().decode(Value.self, from: $0) }
            didSet(newValue)
        }
        return Shared.Subscription(subscription.cancel)
    }
}
