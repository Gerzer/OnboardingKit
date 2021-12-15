//
//  OnboardingTrigger.swift
//  OnboardingKit
//
//  Created by Gabriel Jacoby-Cooper on 10/18/21.
//

/// Supported triggers for checking onboarding events.
public enum OnboardingTrigger {
	
	case launch, manual
	
}

extension Set where Element == OnboardingTrigger {
	
	/// All available onboarding triggers.
	static var all: Self {
		get {
			return [.launch, .manual]
		}
	}
	
}
