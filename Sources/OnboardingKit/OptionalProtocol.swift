//
//  OptionalProtocol.swift
//  OnboardingKit
//
//  Created by Gabriel Jacoby-Cooper on 12/23/21.
//

protocol OptionalProtocol {
	
	static var none: Self { get }
	
}

extension Optional: OptionalProtocol { }
