//
//  UserDefaultsBacked.swift
//  
//
//  Created by Thibaut Richez on 12/24/20.
//

import Foundation

// Since our property wrapper's Value type isn't optional, but
// can still contain nil values, we'll have to introduce this
// protocol to enable us to cast any assigned value into a type
// that we can compare against nil. Otherwise setting a nil value
// would crash
private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

/// A `propertyWrapper` that allows to define values that
/// are backed by `UserDefaults`.
///
/// - Note: Unfortunately we cannot reference `self` when
/// initializing a `propertyWrapper`. Thus `UserRepository`
/// is a `class` in order to be able to update its `container`
/// property in the caller object.
///
/// Example:
/// ```
///     struct Object {
///         /// @UserRepository(..., container: self.defaults, ...) -> Cannot find 'self' in scope
///         @UserRepository(key: .testing, defaultValue: false)
///         var isTesting: Bool
///
///         private let defaults: UserDefaults
///
///         init(defaults: UserDefaults) {
///             self.defaults = defaults
///             self._isTesting.container = defaults
///         }
/// ```
///
/// If you don't plan to unit test the `Object.isTesting` behavior, you can ignore
/// the exemple `init` implementation.
///
/// Follow-up: Allowing the reference of `self` is under discussion in the Swift evolution
/// proposals: https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md#referencing-the-enclosing-self-in-a-wrapper-type
@propertyWrapper
public final class UserDefaultsBacked<Value> {
    let key: String
    var container: UserDefaults
    let defaultValue: Value

    public var projectedValue: UserDefaultsBacked { self }

    public init(key: String,
         container: UserDefaults = .standard,
         default defaultValue: @autoclosure () -> Value) {
        self.key = key
        self.container = container
        self.defaultValue = defaultValue()
    }

    public var wrappedValue: Value {
        get {
            let value = self.container.value(forKey: self.key) as? Value
            return value ?? self.defaultValue
        } set {
            if let optionalValue = newValue as? AnyOptional, optionalValue.isNil {
                self.remove()
            } else {
                self.container.setValue(newValue, forKey: self.key)
            }
        }
    }

    public func remove() {
        self.container.removeObject(forKey: self.key)
    }
}

public extension UserDefaultsBacked where Value: ExpressibleByNilLiteral {
    // Allow to not be obligated to add `nil` as a default value for optional property.
    convenience init(key: String, container: UserDefaults = .standard) {
        self.init(key: key, container: container, default: nil)
    }
}
