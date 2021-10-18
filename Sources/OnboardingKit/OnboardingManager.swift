//
//  OnboardingManager.swift
//  OnboardingKit
//
//  Created by Gabriel Jacoby-Cooper on 10/18/21.
//

public typealias DefaultOnboardingManager = OnboardingManager<EmptyFlags>

public final class OnboardingManager<Flags> where Flags: OnboardingFlags {
	
	@resultBuilder public struct Builder {
		
		public static func buildBlock(_ components: OnboardingEventProtocol...) -> [OnboardingEventProtocol] {
			return components
		}
		
	}
	
	public struct Proxy {
		
		private let manager: OnboardingManager
		
		fileprivate init(_ manager: OnboardingManager) {
			self.manager = manager
		}
		
		public func add(_ event: OnboardingEventProtocol) {
			self.manager.add(event)
		}
		
	}
	
	private var events = [OnboardingEventProtocol]()
	
	private var configured = false
	
	public let flags: Flags
	
	public init(flags: Flags, @Builder events: (Flags) -> [OnboardingEventProtocol]) {
		self.flags = flags
		self.events = events(self.flags)
		self.register()
	}
	
	public init(flags: Flags, _ configurator: (Proxy, Flags) -> Void) {
		self.flags = flags
		configurator(Proxy(self), self.flags)
		self.register()
	}
	
	private func add(_ event: OnboardingEventProtocol) {
		guard !self.configured else {
			fatalError("Error: Can't add an onboarding event to an onboarding manager that has already been configured")
		}
		self.events.append(event)
	}
	
	private func register() {
		self.events.forEach { (event) in
			event.register()
		}
	}
	
	private func check() {
		self.events.forEach { (event) in
			event.check()
		}
	}
	
}

public extension OnboardingManager where Flags: InitializableOnboardingFlags {
	
	convenience init(@Builder events: (Flags) -> [OnboardingEventProtocol]) {
		self.init(flags: Flags(), events: events)
	}
	
	convenience init(_ configurator: (Proxy, Flags) -> Void) {
		self.init(flags: Flags(), configurator)
	}
	
}

public final class EmptyFlags: InitializableOnboardingFlags {
	
	public init() { }
	
}
