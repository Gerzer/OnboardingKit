//
//  OnboardingEvent.swift
//  OnboardingKit
//
//  Created by Gabriel Jacoby-Cooper on 10/18/21.
//

public protocol OnboardingEventProtocol {
	
	var triggers: Set<OnboardingTrigger> { get }
	
	func register()
	
	func check()
	
}

public final class OnboardingEvent<Flags, Value>: OnboardingEventProtocol where Flags: OnboardingFlags {
	
	@resultBuilder public struct Builder {
		
		public static func buildBlock(_ components: OnboardingCondition...) -> [OnboardingCondition] {
			return components
		}
		
	}
	
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
	
	public convenience init(flags: Flags, value: Value, _ handler: @escaping ((Value) -> Void), @Builder conditions: () -> [OnboardingCondition]) {
		self.init(flags: flags, value: value, conditions: conditions())
		self.handler = handler
	}
	
	public convenience init(flags: Flags, settingFlagAt keyPath: ReferenceWritableKeyPath<Flags, Value>, to value: Value, @Builder conditions: () -> [OnboardingCondition]) {
		self.init(flags: flags, value: value, conditions: conditions())
		self.keyPath = keyPath
	}
	
	public func register() {
		self.conditions
			.compactMap { (condition) in
				return condition as? RegistrableOnboardingCondition
			}
			.forEach { (condition) in
				type(of: condition).register()
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
		}
	}
	
}

public extension OnboardingEvent where Value == Bool {

	convenience init(flags: Flags, _ handler: @escaping ((Bool) -> Void), @Builder conditions: () -> [OnboardingCondition]) {
		self.init(flags: flags, value: true, handler, conditions: conditions)
	}

	convenience init(flags: Flags, settingFlagAt keyPath: ReferenceWritableKeyPath<Flags, Bool>, @Builder conditions: () -> [OnboardingCondition]) {
		self.init(flags: flags, settingFlagAt: keyPath, to: true, conditions: conditions)
	}

}
