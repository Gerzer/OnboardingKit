//
//  OnboardingCondition.swift
//  OnboardingKit
//
//  Created by Gabriel Jacoby-Cooper on 10/18/21.
//

import Foundation

public protocol OnboardingCondition {
	
	static var trigger: OnboardingTrigger { get }
	
	func check() -> Bool
	
}

protocol RegisterableOnboardingCondition: OnboardingCondition {
	
	static func register()
	
}

public enum OnboardingConditions {

	public struct ColdLaunch: RegisterableOnboardingCondition {
		
		public static let trigger = OnboardingTrigger.launch
		
		private static let defaultsKey = "ColdLaunchCount"
		
		private static var registered = false
		
		private let threshold: UInt
		
		static func register() {
			guard !self.registered else {
				fatalError("Error: Cold-launch onboarding condition must be registered exactly once")
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
	
}
