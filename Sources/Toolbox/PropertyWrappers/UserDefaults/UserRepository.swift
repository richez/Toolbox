//
//  UserRepository.swift
//  
//
//  Created by Thibaut Richez on 12/24/20.
//

import Foundation

/// An example of how `UserDefaultsBacked` can be used inside your app.
enum UserRepository {}

// MARK: - Keys

extension UserRepository {
    enum Key: String {
        case sessionCount

        case didShowAppOnboarding
        case didShowFeatureOnbording
    }
}

// MARK: -

extension UserRepository {
    struct Session {
        @UserDefaultsBacked(key: .sessionCount, default: 1)
        var count: Int

        init(container: UserDefaults = .standard) {
            self._count.container = container
        }
    }

    struct Onbarding {
        @UserDefaultsBacked(key: .didShowAppOnboarding, default: false)
        var didShowAppOnboarding: Bool

        @UserDefaultsBacked(key: .didShowFeatureOnbording, default: false)
        var didShowFeatureOnbording: Bool

        init(container: UserDefaults = .standard) {
            self._didShowAppOnboarding.container = container
            self._didShowFeatureOnbording.container = container
        }
    }
}

// MARK: - UserDefaultsBacked
extension UserDefaultsBacked {
    convenience init(key: UserRepository.Key,
                     container: UserDefaults = .standard,
                     default defaultValue: @autoclosure () -> Value) {
        self.init(key: key.rawValue, container: container, default: defaultValue())
    }
}

extension UserDefaultsBacked where Value: ExpressibleByNilLiteral {
    convenience init(key: UserRepository.Key,
                     container: UserDefaults = .standard) {
        self.init(key: key.rawValue, container: container, default: nil)
    }
}
