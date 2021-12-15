//
//  OnboardingFlags.swift
//  OnboardingKit
//
//  Created by Gabriel Jacoby-Cooper on 10/18/21.
//

import Foundation

/// The protocol to which all classes instances of which you want to use as flags objects must conform.
public protocol OnboardingFlags: ObservableObject { }

/// A flags type that supports being automatically initialized by ``OnboardingManager``.
public protocol InitializableOnboardingFlags: OnboardingFlags {
	
	init()
	
}

public final class EmptyFlags: InitializableOnboardingFlags {
	
	public init() { }
	
}
