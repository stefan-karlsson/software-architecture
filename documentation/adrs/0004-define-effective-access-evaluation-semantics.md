# Define effective-access evaluation semantics

## Status

* Status: proposed

## Resolve how effective access is computed across scopes

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The platform foundation defines the authorization chain as `Principal -> Membership -> Grant -> Role -> Permission -> Scope`.
That model is architecturally sound, but it is not yet decision-complete for implementation because several effective-access semantics remain unspecified.

Examples of unresolved questions include:

* how direct grants and group-derived grants combine
* whether explicit deny exists and how it behaves
* how overlapping grants at different scopes are merged
* whether broader-scope grants flow downward automatically or are interpreted only through scope resolution

Without these decisions, different teams can implement materially different access behavior while still claiming to follow the architecture.

## Decision Drivers

* Consistent authorization behavior across all platform capabilities
* Least-privilege enforcement
* Predictable scope resolution
* Testable allow/deny behavior
* Reduced risk of grant explosion and ambiguous access

## Considered Options

* Resolve access through additive grants only, with policy handling all denials and restrictions
* Support additive grants plus explicit deny semantics
* Resolve access by nearest-scope precedence only

## Decision Outcome

To be decided. This ADR exists to make the effective-access semantics explicit before implementation proceeds.

## Consequences

* Once decided, this ADR should drive updates to sections 6, 8, and 10.
* The chosen semantics should be reflected in test cases for scope inheritance, group membership, and privileged actions.
