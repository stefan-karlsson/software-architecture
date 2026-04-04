# Adopt a multi-surface browser architecture with thin apps, browser feature modules, and shared browser foundations

## Status

* Status: accepted

## Choose the platform browser-application strategy for cross-team frontend scaling

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The Platform Control Plane already assumes browser-based administration, but it does not yet define how the platform browser surfaces should scale across multiple teams without fragmenting the user experience or creating parallel frontend platforms.

Without a concrete browser-application architecture, teams can still make materially different assumptions about:

* whether the platform uses one browser application or a small number of purpose-specific browser surfaces
* whether the app and administrative experiences are implemented as thin shells or as feature-heavy monoliths
* who owns sign-in handoff, layout, navigation, shared browser contracts, observability conventions, and bounded failure handling
* how feature teams contribute browser feature modules and capability ownership without breaking the shared user experience
* how frontend composition works at runtime without coupling teams through direct frontend-to-frontend dependencies

The platform therefore needs one accepted browser-application architecture that supports cross-team frontend delivery while keeping the user experience, shell responsibilities, and backend integration model coherent inside one Platform Control Plane software-system boundary.

## Decision Drivers

* Clear platform browser surfaces with distinct purposes
* Scalable cross-team delivery without separate frontend platforms per team
* Clear ownership of app concerns versus team-owned browser-feature-module concerns
* Independent delivery of browser capabilities without requiring full app redeploys for every change
* Compatibility with the public API model defined in [ADR 0008](./0008-select-platform-access-interface-and-automation-protocol-profile.md)
* Technology-agnostic architecture guidance that does not prematurely lock a framework

## Considered Options

* Purpose-specific browser apps with thin apps, browser-feature-module-loaded business features, and shared browser foundations
* One shared shell app with team-owned browser slices composed at runtime
* Separate full-screen browser applications per team linked only by navigation conventions

## Decision Outcome

Chosen option: "Purpose-specific browser apps with thin apps, browser-feature-module-loaded business features, and shared browser foundations", because it separates marketing, tenant, administration, and login concerns while still allowing teams to deliver browser feature modules independently without creating parallel frontend platforms.

### Normative Browser-Application Profile

* `www.example.com` serves the marketing app.
* `app.example.com` serves the tenant app.
* `admin.example.com` serves the administration app.
* `login.example.com` serves the sign-in app.
* These browser applications are user-facing runtime containers inside the Platform Control Plane software system.
* The tenant app and administration app stay thin and compose business capabilities through browser feature modules as the preferred default.
* Shared browser contracts and supporting browser-platform code span all browser surfaces so sign-in, navigation, visual language, and client-side integration stay coherent.
* Business features live in browser feature modules and integrate through the shared Platform Management API instead of direct frontend-to-frontend coupling.

### Surface Responsibilities

* Marketing app owns anonymous product marketing, acquisition journeys, and public-facing content flows.
* Tenant app owns tenant user entry, application chrome, tenant navigation, session handoff, and browser-feature-module composition for tenant capabilities.
* Administration app owns administrative entry, admin navigation, session handoff, and browser-feature-module composition for platform administration capabilities.
* Sign-in app owns login, logout, and authentication-oriented journeys shared by the other browser surfaces.

### Thin-App Responsibilities

* Keep page chrome, navigation, session bootstrap and handoff, browser-feature-module composition, and bounded runtime error isolation.
* Consume and enforce shared browser contracts for visual language, sign-in context, telemetry, and client-side integration.
* Stay thin by delegating business workflows and domain-heavy UI to browser feature modules.

### Browser Feature Module Responsibilities

* Deliver business features for an assigned bounded domain area.
* Act as the browser unit a feature team ships for that area.
* Render only inside the integration boundaries assigned by the host app.
* Use shared browser contracts and foundations rather than reimplementing sign-in, telemetry, or navigation behavior.
* Call approved backend public APIs rather than coupling directly to other browser feature modules.
* Fail in a way that the host app can isolate without collapsing the whole browser surface.

### Shared Browser Foundations

* Shared browser foundations keep shared browser contracts and reusable browser foundations explicit across all browser surfaces.
* Design-system assets provide shared visual language and reusable UI foundations across all browser surfaces.
* API clients and SDKs/libraries provide shared client-side integration primitives for backend APIs and browser application concerns.
* Auth and session contracts define how browser surfaces bootstrap, hand off, and consume identity/session state.
* Telemetry conventions define the shared event, trace, and error-observability posture.
* Shared navigation primitives define how apps and browser feature modules contribute navigational structure without creating incompatible patterns.
* Shared browser foundations may expose additional browser-platform code as needed, as long as ownership and compatibility remain explicit.

### Preferred Defaults and Constraints

* Browser feature modules are independently deliverable from the tenant app and administration app.
* Tenant app and administration app use runtime composition to load browser feature modules.
* The specific runtime composition mechanism remains a follow-up implementation choice.
* Marketing and auth surfaces may stay more centrally owned, but they still follow the shared browser contracts and foundations.
* Apps do not absorb domain-heavy business logic that belongs in browser feature modules.
* Browser feature modules do not create direct frontend-to-frontend runtime coupling as their integration mechanism.
* This ADR stays pattern-level and does not choose a specific frontend framework, router, or bundler.

### Positive Consequences

* The platform gets clear browser surfaces for marketing, tenant, admin, and login concerns.
* Cross-team scaling improves because business features live in browser feature modules instead of thick apps or separate frontend platforms.
* Shared browser foundations stay explicit, reusable, and versioned across all browser surfaces.
* The architecture stays compatible with [ADR 0008](./0008-select-platform-access-interface-and-automation-protocol-profile.md), where browser applications remain clients of the shared Platform Management API.

### Negative Consequences

* App governance, browser-feature-module compatibility management, and shared-contract stewardship become explicit architecture concerns.
* Runtime composition failures must be handled deliberately to avoid broken tenant or administrative browser experiences.
* Team autonomy is bounded by app contracts and shared browser conventions.

### Non-Goals and Deferred Decisions

* This ADR does not choose a specific JavaScript framework, router, bundler, or testing stack.
* This ADR does not define a detailed app-to-browser-feature-module wire contract or packaging format.
* This ADR does not prohibit future exceptions, but exceptions require explicit architectural justification.
* This ADR does not replace [ADR 0008](./0008-select-platform-access-interface-and-automation-protocol-profile.md), which still owns the public browser UI plus backend API interaction model.

## Consequences

* The browser-based administration direction in [ADR 0008](./0008-select-platform-access-interface-and-automation-protocol-profile.md) should reference this ADR as the accepted browser-composition and frontend-scaling guidance.
* The arc42 chapters should stop treating browser application structure as unspecified and should describe the marketing, tenant, admin, and login surfaces explicitly.
* The architecture model should represent the tenant app, administration app, sign-in app, and marketing app explicitly as in-scope containers of the Platform Control Plane, while showing browser feature modules and shared browser concepts at the right level of detail.

## Validation Questions

* Can multiple teams deliver browser features through browser feature modules without creating separate frontend platforms?
* Can tenant and administration browser feature modules be deployed independently without forcing full app redeploys?
* Do the tenant app and administration app stay thin while business features live in browser feature modules?
* Can a browser feature module fail or become unavailable without taking down the whole host app?
* Do all browser surfaces share the agreed browser contracts for design system, client integration, auth/session, telemetry, and navigation?

## Pros and Cons of the Options

### Purpose-specific browser apps with thin apps, browser-feature-module-loaded business features, and shared browser foundations

* Good, because it separates marketing, tenant, admin, and login concerns into clear browser surfaces.
* Good, because the tenant and administration apps can stay thin while business features live in browser feature modules.
* Good, because shared browser foundations can be reused consistently across all browser applications.
* Bad, because multiple browser surfaces plus browser-feature-module composition increase governance and compatibility complexity.

### One shared shell app with team-owned browser slices composed at runtime

* Good, because it reduces the number of visible browser surfaces to reason about.
* Good, because runtime composition still enables independent team delivery.
* Bad, because marketing, tenant, admin, and login concerns become too compressed into one browser boundary.
* Bad, because distinct user journeys and operational concerns are harder to separate cleanly.

### Separate full-screen browser applications per team linked through navigation conventions

* Good, because each team gets maximal local autonomy.
* Bad, because the user experience fragments into multiple frontend platforms.
* Bad, because shared browser contracts for sign-in, telemetry, navigation, and visual language are likely to drift apart.
