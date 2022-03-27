//
//  OnboardingCondition.swift
//  OnboardingKit
//
//  Created by Gabriel Jacoby-Cooper on 10/18/21.
//

import Foundation

/// A condition that can be checked to determine whether a particular event occured.
public protocol OnboardingCondition {
	
	/// A set of triggers that indicate when the condition should be checked.
	static var triggers: Set<OnboardingTrigger> { get }
	
	/// Whether the condition is currently satisfied.
	/// - Complexity: This property might take greater than `O(1)` time to compute for some condition types. For example, ``OnboardingConditions/Disjunction`` takes `O(n)` time when it contains only one level of nesting, where `n` is the number of child conditions.
	var isSatisfied: Bool { get }
	
}

/// A condition that must be registered on every cold launch.
protocol RegistrableOnboardingCondition: OnboardingCondition {
	
	/// Configures the condition prior to being checked for the first time.
	/// - Warning: Don’t call this method yourself.
	func register()
	
}

/// A namespace that contains all of the built-in conditions.
public enum OnboardingConditions {
	
	/// A condition that checks how many times the app has been cold-launched.
	///
	/// A “cold launch” occurs when the app is first opened after having been removed from memory.
	public struct ColdLaunch: RegistrableOnboardingCondition {
		
		public static let triggers: Set<OnboardingTrigger> = [.launch]
		
		private static let defaultsKey = "ColdLaunchCount"
		
		private static var registered = false
		
		public var isSatisfied: Bool {
			get {
				let coldLaunchCount = UserDefaults.standard.integer(forKey: Self.defaultsKey)
				return self.comparator(coldLaunchCount, self.threshold)
			}
		}
		
		/// The number of cold launches that should satisfy this condition.
		public let threshold: Int
		
		/// A function that compares the current value with the specified threshold value.
		/// - Remark: The first parameter is the current value, while the second parameter is the threshold value.
		public let comparator: (Int, Int) -> Bool
		
		/// Creates a cold-launch condition.
		/// - Parameters:
		///   - threshold: The threshold value that’s given to the comparator.
		///   - comparator: A function that compares the current value with the specified threshold value.
		public init(threshold: Int, comparator: @escaping (Int, Int) -> Bool = (==)) {
			self.threshold = threshold
			self.comparator = comparator
		}
		
		func register() {
			guard !Self.registered else {
				return
			}
			let coldLaunchCount = UserDefaults.standard.integer(forKey: Self.defaultsKey)
			UserDefaults.standard.set(coldLaunchCount + 1, forKey: Self.defaultsKey)
			Self.registered = true
		}
		
	}
	
	/// A condition that checks whether a persistent counter satisfies a given comparator.
	public struct ManualCounter: OnboardingCondition {
		
		/// A structure that can be passed around to enable the manipulation of the underlying counter from other parts of a codebase.
		public struct Handle {
			
			private let defaultsKey: String
			
			fileprivate init(defaultsKey: String) {
				self.defaultsKey = defaultsKey
			}
			
			/// Adds `1` to the underlying counter.
			public func increment() {
				let count = UserDefaults.standard.integer(forKey: self.defaultsKey)
				UserDefaults.standard.set(count + 1, forKey: self.defaultsKey)
			}
			
			/// Subtracts `1` from the underlying counter.
			public func decrement() {
				let count = UserDefaults.standard.integer(forKey: self.defaultsKey)
				UserDefaults.standard.set(count - 1, forKey: self.defaultsKey)
			}
			
			/// Resets the counter to `0`.
			public func reset() {
				UserDefaults.standard.set(0, forKey: self.defaultsKey)
			}
			
		}
		
		public static let triggers: Set<OnboardingTrigger> = [.launch, .manual]
		
		public var isSatisfied: Bool {
			get {
				let count = UserDefaults.standard.integer(forKey: self.defaultsKey)
				return self.comparator(count, self.threshold)
			}
		}
		
		/// The key that’s used to store the value of this counter with `UserDefaults`.
		public let defaultsKey: String
		
		/// The threshold value that’s given to the comparator.
		public let threshold: Int
		
		/// A function that compares the current value with the specified threshold value.
		/// - Remark: The first parameter is the current value, while the second parameter is the threshold value.
		public let comparator: (Int, Int) -> Bool
		
		/// Creates a manual-counter condition.
		/// - Parameters:
		///   - defaultsKey: The key that’s used to store the value of the counter with `UserDefaults`.
		///   - threshold: The threshold value that’s given to the comparator.
		///   - comparator: A function that compares the current value with the specified threshold value.
		public init(defaultsKey: String, threshold: Int, comparator: @escaping (Int, Int) -> Bool = (==)) {
			self.defaultsKey = defaultsKey
			self.threshold = threshold
			self.comparator = comparator
		}
		
		/// Creates a manual-counter condition.
		/// - Parameters:
		///   - defaultsKey: The key that’s used to store the value of the counter with `UserDefaults`.
		///   - threshold: The threshold value that’s given to the comparator.
		///   - keyPath: A key path to the property in which the condition should store its handle.
		///   - handleContainer: The container object to a property of which the key path points.
		///   - comparator: A function that compares the current value of the counter with the specified threshold value.
		public init<HandleContainer>(defaultsKey: String, threshold: Int, settingHandleAt keyPath: ReferenceWritableKeyPath<HandleContainer, Handle>, in handleContainer: HandleContainer, comparator: @escaping (Int, Int) -> Bool = (==)) {
			self.init(defaultsKey: defaultsKey, threshold: threshold, comparator: comparator)
			handleContainer[keyPath: keyPath] = Handle(defaultsKey: defaultsKey)
		}
		
		/// Creates a manual-counter condition.
		/// - Parameters:
		///   - defaultsKey: The key that’s used to store the value of the counter with `UserDefaults`.
		///   - threshold: The threshold value that’s given to the comparator.
		///   - keyPath: A key path to the property in which the condition should store its handle.
		///   - handleContainer: The container object to a property of which the key path points.
		///   - comparator: A function that compares the current value of the counter with the specified threshold value.
		public init<HandleContainer>(defaultsKey: String, threshold: Int, settingHandleAt keyPath: ReferenceWritableKeyPath<HandleContainer, Handle?>, in handleContainer: HandleContainer, comparator: @escaping (Int, Int) -> Bool = (==)) {
			self.init(defaultsKey: defaultsKey, threshold: threshold, comparator: comparator)
			handleContainer[keyPath: keyPath] = Handle(defaultsKey: defaultsKey)
		}
		
	}
	
	/// A condition that’s satisfied on the first cold launch and never again.
	public struct Once: OnboardingCondition {
		
		public static var triggers: Set<OnboardingTrigger> = [.launch]
		
		public var isSatisfied: Bool {
			get {
				if UserDefaults.standard.bool(forKey: self.defaultsKey) {
					return false
				} else {
					UserDefaults.standard.set(true, forKey: self.defaultsKey)
					return true
				}
			}
		}
		
		/// The key that’s used to store the Boolean flag for this condition with `UserDefaults`.
		public let defaultsKey: String
		
		/// Creates a “once” condition.
		/// - Parameter defaultsKey: The key that’s used to store the Boolean flag for this condition with `UserDefaults`.
		public init(defaultsKey: String) {
			self.defaultsKey = defaultsKey
		}
		
	}
	
	/// A condition that checks how much time has passed since the first launch.
	@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *) public struct TimeSinceFirstLaunch: RegistrableOnboardingCondition {
		
		public static var triggers: Set<OnboardingTrigger> = [.launch, .manual]
		
		private static let defaultsKey = "FirstLaunch"
		
		private static var registered = false
		
		public var isSatisfied: Bool {
			get {
				guard let firstLaunchDate = UserDefaults.standard.object(forKey: Self.defaultsKey) as? Date else {
					return false
				}
				return self.comparator(-firstLaunchDate.timeIntervalSinceNow, self.threshold)
			}
		}
		
		/// The threshold value that’s given to the comparator.
		public let threshold: TimeInterval
		
		/// A function that compares the current value with the specified threshold value.
		/// - Remark: The first parameter is the current value, while the second parameter is the threshold value.
		public let comparator: (TimeInterval, TimeInterval) -> Bool
		
		/// Creates a time-since-first-launch condition.
		/// - Parameters:
		///   - threshold: The threshold value that’s given to the comparator.
		///   - comparator: A function that compares the current value with the specified threshold value.
		public init(threshold: TimeInterval, comparator: @escaping (TimeInterval, TimeInterval) -> Bool = (>)) {
			self.threshold = threshold
			self.comparator = comparator
		}
		
		func register() {
			guard !Self.registered else {
				return
			}
			if UserDefaults.standard.object(forKey: Self.defaultsKey) == nil {
				UserDefaults.standard.set(Date.now, forKey: Self.defaultsKey)
			}
			Self.registered = true
		}
		
	}
	
	/// A condition that checks if a specified date is in the past.
	@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *) public struct AfterDate: OnboardingCondition {
		
		public static var triggers: Set<OnboardingTrigger> = [.launch, .manual]
		
		public var isSatisfied: Bool {
			get {
				return Date.now > self.date
			}
		}
		
		private let date: Date
		
		/// Creates an after-date condition.
		/// - Parameter date: The date after which the condition should be satisfied.
		public init(date: Date) {
			self.date = date
		}
		
	}
	
	/// A condition that checks if all of its child conditions are satisfied.
	///
	/// All top-level conditions are conjuncted by default without the need for this special condition. This condition is most useful when it’s nested inside a ``Disjunction`` condition.
	public struct Conjunction: RegistrableOnboardingCondition {
		
		public static var triggers: Set<OnboardingTrigger> = .all
		
		public var isSatisfied: Bool {
			get {
				return self.conditions.allSatisfy { (condition) in
					return condition.isSatisfied
				}
			}
		}
		
		private let conditions: [OnboardingCondition]
		
		/// Creates a conjunction condition.
		/// - Parameter conditions: An onboarding-condition result builder.
		public init(@OnboardingConditionsBuilder conditions: () -> [OnboardingCondition]) {
			self.conditions = conditions()
		}
		
		func register() {
			self.conditions
				.compactMap { (condition) in
					return condition as? RegistrableOnboardingCondition
				}
				.forEach { (condition) in
					condition.register()
				}
		}
		
	}
	
	/// A condition that checks if at least one of its child conditions is satisfied.
	public struct Disjunction: RegistrableOnboardingCondition {
		
		public static var triggers: Set<OnboardingTrigger> = .all
		
		public var isSatisfied: Bool {
			get {
				return !self.conditions.allSatisfy { (condition) in
					return !condition.isSatisfied
				}
			}
		}
		
		private let conditions: [OnboardingCondition]
		
		/// Creates a disjunction condition.
		/// - Parameter conditions: An onboarding-condition result builder.
		public init(@OnboardingConditionsBuilder conditions: () -> [OnboardingCondition]) {
			self.conditions = conditions()
		}
		
		func register() {
			self.conditions
				.compactMap { (condition) in
					return condition as? RegistrableOnboardingCondition
				}
				.forEach { (condition) in
					condition.register()
				}
		}
		
	}
	
}

/// A result builder that builds an array of onboarding conditions.
/// - Warning: Don’t instantiate this structure yourself; instead, use the result-builder syntax.
@resultBuilder public struct OnboardingConditionsBuilder {
	
	public static func buildExpression(_ expression: OnboardingCondition) -> [OnboardingCondition] {
		return [expression]
	}
	
	public static func buildBlock(_ components: [OnboardingCondition]...) -> [OnboardingCondition] {
		return Array(components.joined())
	}
	
	public static func buildOptional(_ component: [OnboardingCondition]?) -> [OnboardingCondition] {
		return component ?? []
	}
	
	public static func buildEither(first component: [OnboardingCondition]) -> [OnboardingCondition] {
		return component
	}
	
	public static func buildEither(second component: [OnboardingCondition]) -> [OnboardingCondition] {
		return component
	}
	
	public static func buildArray(_ components: [[OnboardingCondition]]) -> [OnboardingCondition] {
		return Array(components.joined())
	}
	
	public static func buildLimitedAvailability(_ component: [OnboardingCondition]) -> [OnboardingCondition] {
		return component
	}
	
}
