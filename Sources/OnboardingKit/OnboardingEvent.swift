//
//  OnboardingEvent.swift
//  OnboardingKit
//
//  Created by Gabriel Jacoby-Cooper on 10/18/21.
//

/// A protocol to which ``OnboardingEvent`` conforms.
/// - Warning: Don’t add conformance to this protocol to any other types.
public protocol OnboardingEventProtocol {
	
	/// The union of the respective sets of triggers for each constituent condition.
	var triggers: Set<OnboardingTrigger> { get }
	
	/// Registers all of the constituent conditions that support registration.
	/// - Warning: Don’t call this method yourself.
	func register()
	
	/// Checks all of the constituent conditions.
	/// - Warning: Don’t call this method yourself.
	func check()
	
	/// Attempts to set the specified flag to a default value.
	///
	/// This method should fail silently if no default value can be inferred.
	/// - Parameter keyPath: The key path at which to set the default value.
	/// - Warning: Don’t call this method yourself.
	func setDefaultValue<Flags, Value>(at keyPath: ReferenceWritableKeyPath<Flags, Value>)
	
}

extension OnboardingEventProtocol {
	
	public func setDefaultValue<Flags, Value>(at: ReferenceWritableKeyPath<Flags, Value>) { }
	
}

/// An event that occurs when all of its constituent conditions are satisfied.
public final class OnboardingEvent<Flags, Value>: OnboardingEventProtocol where Flags: OnboardingFlags {
	
	private var handler: ((Value) -> Void)?
	
	private var keyPath: ReferenceWritableKeyPath<Flags, Value>?
	
	private let value: Value
	
	private let conditions: [OnboardingCondition]
	
	private let flags: Flags
	
	public var triggers = Set<OnboardingTrigger>()
	
	private init(flags: Flags, value: Value, conditions: [OnboardingCondition]) {
		self.flags = flags
		self.value = value
		self.conditions = conditions
		for condition in conditions {
			self.triggers.formUnion(type(of: condition).triggers)
		}
	}
	
	/// Creates an event.
	/// - Parameters:
	///   - flags: An object a property of which you set in the handler when the event occurs.
	///   - value: A value that that’s passed into the handler for context.
	///   - handler: A function that takes in a context value and sets some property on flags object.
	///   - conditions: A builder that configures the constituent conditions.
	public convenience init(flags: Flags, value: Value, _ handler: @escaping ((Value) -> Void), @OnboardingConditionsBuilder conditions: () -> [OnboardingCondition]) {
		self.init(flags: flags, value: value, conditions: conditions())
		self.handler = handler
	}
	
	/// Creates an event.
	/// - Parameters:
	///   - flags: An object a property of which the event sets when all of its conditions are satisfied.
	///   - keyPath: A key path to the property that the event should set.
	///   - value: The value to which the event should set the property that’s specified by the key path.
	///   - conditions: A builder that configures the constituent conditions.
	public convenience init(flags: Flags, settingFlagAt keyPath: ReferenceWritableKeyPath<Flags, Value>, to value: Value, @OnboardingConditionsBuilder conditions: () -> [OnboardingCondition]) {
		self.init(flags: flags, value: value, conditions: conditions())
		self.keyPath = keyPath
	}
	
	public func register() {
		self.conditions
			.compactMap { (condition) in
				return condition as? RegistrableOnboardingCondition
			}
			.forEach { (condition) in
				condition.register()
			}
		if self.triggers.contains(.launch) {
			self.check()
		}
	}
	
	public func check() {
		let doExecute = self.conditions.allSatisfy { (condition) in
			return condition.check()
		}
		if doExecute {
			self.handler?(self.value)
			if let keyPath = self.keyPath {
				self.flags[keyPath: keyPath] = self.value
			}
		} else if let keyPath = self.keyPath {
			self.setDefaultValue(at: keyPath)
		}
	}
	
}

public extension OnboardingEvent where Value == Bool {
	
	/// Creates an event with a default value of `true`.
	/// - Parameters:
	///   - flags: An object a property of which you set in the handler when the event occurs.
	///   - handler: A function that takes in a context value and sets some property on the flags object.
	///   - conditions: A builder that configures the constituent conditions.
	convenience init(flags: Flags, _ handler: @escaping ((Bool) -> Void), @OnboardingConditionsBuilder conditions: () -> [OnboardingCondition]) {
		self.init(flags: flags, value: true, handler, conditions: conditions)
	}
	
	/// Creates an event with a default value of `true`.
	/// - Parameters:
	///   - flags: An object a property of which the event sets when all of its conditions are satisfied.
	///   - keyPath: A key path to the property that the event should set.
	///   - conditions: A builder that configures the constituent conditions.
	convenience init(flags: Flags, settingFlagAt keyPath: ReferenceWritableKeyPath<Flags, Bool>, @OnboardingConditionsBuilder conditions: () -> [OnboardingCondition]) {
		self.init(flags: flags, settingFlagAt: keyPath, to: true, conditions: conditions)
	}
	
	func setDefaultValue(at keyPath: ReferenceWritableKeyPath<Flags, Bool>) {
		self.flags[keyPath: keyPath] = false
	}
	
}

public extension OnboardingEvent where Value: ExpressibleByNilLiteral {
	
	func setDefaultValue(at keyPath: ReferenceWritableKeyPath<Flags, Value>) {
		self.flags[keyPath: keyPath] = nil
	}
	
}
