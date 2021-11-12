//
//  OnboardingCondition.swift
//  OnboardingKit
//
//  Created by Gabriel Jacoby-Cooper on 10/18/21.
//

import Foundation

public protocol OnboardingCondition {
	
	static var triggers: Set<OnboardingTrigger> { get }
	
	func check() -> Bool
	
}

protocol RegistrableOnboardingCondition: OnboardingCondition {
	
	static func register()
	
}

public enum OnboardingConditions {

	public struct ColdLaunch: RegistrableOnboardingCondition {
		
		public static let triggers: Set<OnboardingTrigger> = [.launch]
		
		private static let defaultsKey = "ColdLaunchCount"
		
		private static var registered = false
		
		public let threshold: Int
		
		public init(threshold: Int) {
			self.threshold = threshold
		}
		
		static func register() {
			guard !self.registered else {
				return
			}
			let coldLaunchCount = UserDefaults.standard.integer(forKey: self.defaultsKey)
			UserDefaults.standard.set(coldLaunchCount + 1, forKey: self.defaultsKey)
			self.registered = true
		}
		
		public func check() -> Bool {
			let coldLaunchCount = UserDefaults.standard.integer(forKey: Self.defaultsKey)
			return coldLaunchCount == self.threshold
		}
		
	}
	
	public struct ManualCounter: OnboardingCondition {
		
		public struct Handle {
			
			private let defaultsKey: String
			
			fileprivate init(defaultsKey: String) {
				self.defaultsKey = defaultsKey
			}
			
			public func increment() {
				let count = UserDefaults.standard.integer(forKey: self.defaultsKey)
				UserDefaults.standard.set(count + 1, forKey: self.defaultsKey)
			}
			
			public func decrement() {
				let count = UserDefaults.standard.integer(forKey: self.defaultsKey)
				UserDefaults.standard.set(count - 1, forKey: self.defaultsKey)
			}
			
			public func reset() {
				UserDefaults.standard.set(0, forKey: self.defaultsKey)
			}
			
		}
		
		public static let triggers: Set<OnboardingTrigger> = [.launch, .manual]
		
		public let defaultsKey: String
		
		public let threshold: Int
		
		public let comparator: (Int, Int) -> Bool
		
		public init(defaultsKey: String, threshold: Int, comparator: @escaping (Int, Int) -> Bool) {
			self.defaultsKey = defaultsKey
			self.threshold = threshold
			self.comparator = comparator
		}
		
		public init<HandleContainer>(defaultsKey: String, threshold: Int, settingHandleAt keyPath: ReferenceWritableKeyPath<HandleContainer, Handle>, in handleContainer: HandleContainer, comparator: @escaping (Int, Int) -> Bool) {
			self.init(defaultsKey: defaultsKey, threshold: threshold, comparator: comparator)
			handleContainer[keyPath: keyPath] = Handle(defaultsKey: defaultsKey)
		}
		
		public func check() -> Bool {
			let count = UserDefaults.standard.integer(forKey: self.defaultsKey)
			return self.comparator(count, self.threshold)
		}
		
	}
	
}
