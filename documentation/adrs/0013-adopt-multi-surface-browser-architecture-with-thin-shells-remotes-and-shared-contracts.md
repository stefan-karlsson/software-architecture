# Adopt a multi-surface browser architecture with thin shells, remotes, and a shared platform frontend package

## Status

* Status: proposed

## Choose the platform browser-application strategy for cross-team frontend scaling

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The Platform Control Plane already assumes browser-based administration, but it does not yet define how the platform browser surfaces should scale across multiple teams without fragmenting the user experience or creating parallel frontend platforms.

Without a concrete browser-application architecture, teams can still make materially different assumptions about:

* whether the platform uses one browser application or a small number of purpose-specific browser surfaces
* whether the app and administrative experiences are implemented as thin shells or as feature-heavy monoliths
* who owns sign-in handoff, layout, navigation, shared browser contracts, observability conventions, and bounded failure handling
* how feature teams contribute remotes and capability ownership without breaking the shared user experience
* how frontend composition works at runtime without coupling teams through direct frontend-to-frontend dependencies

The platform therefore needs one proposed browser-application architecture that supports cross-team frontend delivery while keeping the user experience, shell responsibilities, and backend integration model coherent inside one Platform Control Plane software-system boundary.

## Decision Drivers

* Clear platform browser surfaces with distinct purposes
* Scalable cross-team delivery without separate frontend platforms per team
* Clear ownership of shell concerns versus team-owned remote feature concerns
* Independent delivery of browser capabilities without requiring full shell redeploys for every change
* Compatibility with the public API model defined in ADR 0008
* Technology-agnostic architecture guidance that does not prematurely lock a framework

## Considered Options

* Purpose-specific browser apps with thin shells, remote-loaded business features, and a shared platform frontend package
* One shared shell app with team-owned browser slices composed at runtime
* Separate full-screen browser applications per team linked only by navigation conventions

## Proposed Decision Direction

Leading option: "Purpose-specific browser apps with thin shells, remote-loaded business features, and a shared platform frontend package", because it separates marketing, tenant, administration, and login concerns while still allowing teams to deliver remotes independently without creating parallel frontend platforms.

### Proposed Browser-Application Profile

* `www.example.com` serves the marketing site.
* `app.example.com` serves the tenant portal.
* `admin.example.com` serves the administration portal.
* `login.example.com` serves the sign-in portal.
* These browser applications are user-facing runtime containers inside the Platform Control Plane software system.
* The tenant portal and administration portal stay thin and compose business capabilities through remotes as the preferred default.
* Shared browser contracts and supporting browser-platform code span all browser surfaces so sign-in, navigation, visual language, and client-side integration stay coherent.
* Business features live in remotes and integrate through the shared Platform Governance API instead of direct frontend-to-frontend coupling.

### Surface Responsibilities

* Marketing site owns anonymous product marketing, acquisition journeys, and public-facing content flows.
* Tenant portal owns tenant user entry, application chrome, tenant navigation, session handoff, and remote composition for tenant capabilities.
* Administration portal owns administrative entry, admin navigation, session handoff, and remote composition for platform administration capabilities.
* Sign-in portal owns login, logout, and authentication-oriented journeys shared by the other browser surfaces.

### Thin-Shell Responsibilities

* Keep page chrome, navigation, session bootstrap and handoff, feature composition, and bounded runtime error isolation.
* Consume and enforce shared browser contracts for visual language, sign-in context, telemetry, and client-side integration.
* Stay thin by delegating business workflows and domain-heavy UI to remotes.

### Remote Responsibilities

* Deliver business features for an assigned bounded domain area.
* Render only inside the integration boundaries assigned by the host shell.
* Use shared browser contracts and foundations rather than reimplementing sign-in, telemetry, or navigation behavior.
* Call approved backend public APIs rather than coupling directly to other remotes.
* Fail in a way that the host shell can isolate without collapsing the whole browser surface.

### Shared Platform Frontend Package

* The package keeps shared browser contracts and reusable browser foundations explicit across all browser surfaces.
* Design-system assets provide shared visual language and reusable UI foundations across all browser surfaces.
* API clients and SDKs/libraries provide shared client-side integration primitives for backend APIs and browser application concerns.
* Auth and session contracts define how browser surfaces bootstrap, hand off, and consume identity/session state.
* Telemetry conventions define the shared event, trace, and error-observability posture.
* Shared navigation primitives define how shells and remotes contribute navigational structure without creating incompatible patterns.
* The package may expose additional browser-platform code as needed, as long as ownership and compatibility remain explicit.

### Preferred Defaults and Constraints

* Remotes are independently deliverable from the tenant portal and administration portal.
* Tenant portal and administration portal use runtime composition to load remotes.
* The specific runtime composition mechanism remains a follow-up implementation choice.
* Marketing and auth surfaces may stay more centrally owned, but they still follow the shared browser contracts and foundations.
* Shells do not absorb domain-heavy business logic that belongs in remotes.
* Remotes do not create direct frontend-to-frontend runtime coupling as their integration mechanism.
* This ADR stays pattern-level and does not choose a specific frontend framework, router, or bundler.

### Positive Consequences

* The platform gets clear browser surfaces for marketing, tenant, admin, and login concerns.
* Cross-team scaling improves because business features live in remotes instead of thick shells or separate frontend platforms.
* The shared platform frontend package stays explicit, reusable, and versioned across all browser surfaces.
* The architecture stays compatible with ADR 0008, where browser applications remain clients of the shared Platform Governance API.

### Negative Consequences

* Shell governance, remote compatibility management, and shared-contract stewardship become explicit architecture concerns.
* Runtime composition failures must be handled deliberately to avoid broken app or administrative browser experiences.
* Team autonomy is bounded by shell contracts and shared browser conventions.

### Non-Goals and Deferred Decisions

* This ADR does not choose a specific JavaScript framework, router, bundler, or testing stack.
* This ADR does not define a detailed shell-to-remote wire contract or packaging format.
* This ADR does not prohibit future exceptions, but exceptions require explicit architectural justification.
* This ADR does not replace ADR 0008, which still owns the public browser UI plus backend API interaction model.

## Consequences

* The browser-based administration direction in ADR 0008 should reference this ADR for multi-surface browser architecture and frontend scaling guidance.
* The arc42 chapters should stop treating browser application structure as unspecified and should describe the marketing, tenant, admin, and login surfaces explicitly.
* The architecture model should represent the tenant portal, administration portal, sign-in portal, and marketing site explicitly as in-scope containers of the Platform Control Plane, while showing remotes and shared browser concepts at the right level of detail.

## Validation Questions

* Can multiple teams deliver browser features through remotes without creating separate frontend platforms?
* Can tenant and administration remotes be deployed independently without forcing full portal redeploys?
* Do the tenant portal and administration portal stay thin while business features live in remotes?
* Can a remote fail or become unavailable without taking down the whole host shell?
* Do all browser surfaces share the agreed browser contracts for design system, client integration, auth/session, telemetry, and navigation?

## Pros and Cons of the Options

### Purpose-specific browser apps with thin shells, remote-loaded business features, and a shared platform frontend package

* Good, because it separates marketing, tenant, admin, and login concerns into clear browser surfaces.
* Good, because the tenant and administration portals can stay thin while business features live in remotes.
* Good, because the shared platform frontend package can be reused consistently across all browser applications.
* Bad, because multiple browser surfaces plus remote composition increase governance and compatibility complexity.

### One shared shell app with team-owned browser slices composed at runtime

* Good, because it reduces the number of visible browser surfaces to reason about.
* Good, because runtime composition still enables independent team delivery.
* Bad, because marketing, tenant, admin, and login concerns become too compressed into one browser boundary.
* Bad, because distinct user journeys and operational concerns are harder to separate cleanly.

### Separate full-screen browser applications per team linked through navigation conventions

* Good, because each team gets maximal local autonomy.
* Bad, because the user experience fragments into multiple frontend platforms.
* Bad, because shared browser contracts for sign-in, telemetry, navigation, and visual language are likely to drift apart.
