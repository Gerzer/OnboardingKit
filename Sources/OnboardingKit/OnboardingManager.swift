//
//  OnboardingManager.swift
//  OnboardingKit
//
//  Created by Gabriel Jacoby-Cooper on 10/18/21.
//

import Foundation

/// An onboarding manager with empty flags.
public typealias DefaultOnboardingManager = OnboardingManager<EmptyFlags>

/// A manager class that configures an onboarding flow with a declarative API.
public final class OnboardingManager<Flags> where Flags: OnboardingFlags {
	
	/// A result builder that builds an array of onboarding events.
	/// - Warning: Don’t instantiate this structure yourself; instead, use the result-builder syntax.
	@resultBuilder public struct Builder {
		
		public static func buildBlock(_ components: [OnboardingEventProtocol]...) -> [OnboardingEventProtocol] {
			return Array(components.joined())
		}
		
		public static func buildExpression(_ expression: OnboardingEventProtocol) -> [OnboardingEventProtocol] {
			return [expression]
		}
		
		public static func buildOptional(_ component: [OnboardingEventProtocol]?) -> [OnboardingEventProtocol] {
			return component ?? []
		}
		
		public static func buildEither(first component: [OnboardingEventProtocol]) -> [OnboardingEventProtocol] {
			return component
		}
		
		public static func buildEither(second component: [OnboardingEventProtocol]) -> [OnboardingEventProtocol] {
			return component
		}
		
		public static func buildArray(_ components: [[OnboardingEventProtocol]]) -> [OnboardingEventProtocol] {
			return Array(components.joined())
		}
		
		public static func buildLimitedAvailability(_ component: [OnboardingEventProtocol]) -> [OnboardingEventProtocol] {
			return component
		}
		
	}
	
	/// A proxy type that’s provided to the configuration closure for an onboarding manager.
	public struct Proxy {
		
		private let manager: OnboardingManager
		
		fileprivate init(manager: OnboardingManager) {
			self.manager = manager
		}
		
		/// Adds an event to the onboarding manager that created this proxy.
		/// - Parameter event: The event to add.
		public func add(_ event: OnboardingEventProtocol) {
			self.manager.add(event)
		}
		
	}
	
	private var events = [OnboardingEventProtocol]()
	
	private var hasBeenConfigured = false
	
	/// The flags object that this onboarding manager provides to its constituent events.
	public let flags: Flags
	
	/// Creates an onboarding manager.
	/// - Parameters:
	///   - flags: A flags object the properties of which events in the onboarding manager can set when they’re triggered.
	///   - events: A result builder that specifies the onboarding events.
	public init(flags: Flags, @Builder events: (Flags) -> [OnboardingEventProtocol]) {
		self.flags = flags
		self.events = events(self.flags)
		self.register()
	}
	
	/// Creates an onboarding manager.
	/// - Parameters:
	///   - flags: A flags object the properties of which events in the onboarding manager can set when they’re triggered.
	///   - configurator: A closure that configures the onboarding manager via a ``Proxy`` instance.
	public init(flags: Flags, configurator: (Proxy, Flags) -> Void) {
		self.flags = flags
		configurator(Proxy(manager: self), self.flags)
		self.register()
	}
	
	private func add(_ event: OnboardingEventProtocol) {
		guard !self.hasBeenConfigured else {
			fatalError("Error: Can't add an onboarding event to an onboarding manager that has already been configured")
		}
		self.events.append(event)
	}
	
	private func register() {
		for event in self.events {
			event.register()
		}
	}
	
	private func check() {
		for event in events {
			event.check()
		}
	}
	
	/// Increments a manual counter by `1`.
	/// - Parameter defaultsKey: The `UserDefaults` key for the counter.
	public func incrementManualCounter(forDefaultsKey defaultsKey: String) {
		let count = UserDefaults.standard.integer(forKey: defaultsKey)
		UserDefaults.standard.set(count + 1, forKey: defaultsKey)
	}
	
	/// Checks all events that support manual checking to see if they’ve been triggered.
	public func checkManually() {
		self.events
			.filter { (event) in
				return event.triggers.contains(.manual)
			}
			.forEach { (event) in
				event.check()
			}
	}
	
}

public extension OnboardingManager where Flags: InitializableOnboardingFlags {
	
	/// Creates an onboarding manager.
	/// - Parameter events: A result builder that specifies the onboarding events.
	convenience init(@Builder events: (Flags) -> [OnboardingEventProtocol]) {
		self.init(flags: Flags(), events: events)
	}
	
	/// Creates an onboarding manager.
	/// - Parameter configurator: A closure that configures the onboarding manager via a ``Proxy`` instance.
	convenience init(configurator: (Proxy, Flags) -> Void) {
		self.init(flags: Flags(), configurator: configurator)
	}
	
}
