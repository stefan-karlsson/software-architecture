# Define hybrid isolation resolution rules

## Status

* Status: proposed

## Resolve how hybrid isolation is selected and constrained

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The platform foundation supports shared, silo, and hybrid isolation through isolation profile plus runtime, data, and network boundaries.
Hybrid is intentionally first-class, but the architecture does not yet define exactly how hybrid placement is resolved when subscription defaults, inherited policy, and environment-specific tightening all apply.

The unresolved questions include:

* whether runtime, data, and network boundaries may diverge independently
* whether environment-level choices may tighten subscription defaults
* which policy constraints run before final placement is accepted
* how hybrid behavior is represented for auditing and operational review

## Decision Drivers

* Predictable placement behavior
* Clear relationship between subscription plan, isolation profile, and policy
* Testable hybrid behavior
* Reduced ambiguity for platform operators and service teams

## Considered Options

* Resolve all boundaries together from one shared isolation decision
* Resolve runtime, data, and network boundaries independently under a common policy envelope
* Restrict hybrid behavior to predefined patterns only

## Decision Outcome

To be decided. This ADR exists to make hybrid isolation behavior explicit before implementation and tenant onboarding depend on local interpretation.

## Consequences

* Once decided, this ADR should drive updates to sections 6, 7, and 10.
* The chosen rules should be reflected in placement, policy, and audit scenarios.
