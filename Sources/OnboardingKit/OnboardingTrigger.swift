//
//  OnboardingTrigger.swift
//  OnboardingKit
//
//  Created by Gabriel Jacoby-Cooper on 10/18/21.
//

public enum OnboardingTrigger {
	
	case launch, manual
	
}

extension Set where Element == OnboardingTrigger {
	
	static var all: Self {
		get {
			return [.launch, .manual]
		}
	}
	
}
