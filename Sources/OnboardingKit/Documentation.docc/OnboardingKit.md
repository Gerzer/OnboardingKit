# ``OnboardingKit``

Easy onboarding logic with a declarative API.

## Overview

OnboardingKit makes it easy to specify your onboarding logic with a declarative API. It’s not a UI framework; rather, it abstracts away much of the core logic that determines *when* to display onboarding UI flows so that you can focus on design. OnboardingKit integrates especially well with SwiftUI, but it’s also flexible enough to work in every other situation.

The top-level component of OnboardingKit is ``OnboardingManager``. Typically, you instantiate this class only once upon the launch of your app; if you use the SwiftUI lifecycle, then this would occur in a custom `init()` implementation in your main app structure (*i.e.*, the structure that both conforms to the `App` protocol and is tagged with the `@main` decorator). Remember to maintain a strong reference to the object at all times, or else your onboarding events won’t be properly triggered.

An ``OnboardingManager`` instance contains a collection of onboarding events, which are represented as instances of the ``OnboardingEvent`` class. Each ``OnboardingEvent`` instance represents a particular event that might occur as the user uses your app. When an onboarding event occurs, OnboardingKit can notify your app in one of two ways: it can set a property on a ”flags” object (*i.e.*, an instance of a class that conforms to the ``OnboardingFlags`` protocol) that you specify, or it can just call a handler function that you provide.

Each onboarding event contains a collection of onboarding conditions, which are structures that conform to the ``OnboardingCondition`` protocol. An event is triggered when **all** of its conditions are satisfied. All of the built-in conditions are contained in the ``OnboardingConditions`` namespace. To enable more dynamic onboarding flows, OnboardingKit provides a special ``OnboardingConditions/Disjunction`` condition that is satisfied when **any** of its child conditions are satified.

Events must be intentionally checked to see if they have been triggered; OnboardingKit won’t update your UI unless some event is checked and determined to have occured. Currently, OnboardingKit provides two ways to check events: it can check them automatically every time you app launches, and it can check them when you manually call ``OnboardingManager/checkManually()``. Each event automatically determines the manner in which it’s checked, so it’s a good idea to call ``OnboardingManager/checkManually()`` whenever you think that an onboarding event could possibly have occured. More automated ways to check events may be added in the future.

## Topics

### Onboarding

- ``OnboardingManager``
- ``OnboardingEvent``
- ``OnboardingCondition``
- ``OnboardingFlags``
- ``OnboardingTrigger``
