//
//  OnboardingFlags.swift
//  OnboardingKit
//
//  Created by Gabriel Jacoby-Cooper on 10/18/21.
//

import Foundation

public protocol OnboardingFlags: ObservableObject { }

public protocol InitializableOnboardingFlags: OnboardingFlags {
	
	init()
	
}
