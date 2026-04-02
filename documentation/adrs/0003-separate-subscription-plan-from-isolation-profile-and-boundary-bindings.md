# Separate subscription plan from isolation profile and boundary bindings

## Status

* Status: accepted

## Distinguish customer entitlement from technical isolation

* Deciders: Architecture Team
* Date: 2026-04-02

## Context and Problem Statement

The platform must support tenants that buy different subscription plans and also require different isolation models.
If pricing and isolation are treated as the same field, the architecture becomes harder to reason about and less flexible for shared, silo, and hybrid deployment choices.

## Decision Drivers

* Clear separation between business entitlement and technical isolation
* Support for shared, silo, and hybrid operating models
* Ability to change placement and isolation without changing the tenant hierarchy
* Better policy evaluation for runtime, data, and network boundaries

## Considered Options

* Separate subscription plan from isolation profile and boundary bindings
* Use one combined concept for pricing and isolation

## Decision Outcome

Chosen option: "Separate subscription plan from isolation profile and boundary bindings", because it preserves one tenant model while allowing hosting isolation to vary independently.

### Positive Consequences

* A subscription can express both commercial entitlement and technical isolation intent.
* The same tenant hierarchy works for shared, silo, and hybrid tenants.
* Runtime binding, data boundary, and network boundary can be resolved independently from pricing.
* Hybrid isolation can be modeled without redefining the business hierarchy.

### Negative Consequences

* Teams must understand two related but distinct concepts instead of one simplified field.
* Isolation resolution requires explicit logic for runtime, data, and network boundaries.

## Pros and Cons of the Options

### Separate subscription plan from isolation profile and boundary bindings

* Good, because pricing and isolation remain conceptually clean.
* Good, because hybrid cases are easier to express.
* Bad, because the model contains more moving parts.

### Use one combined concept for pricing and isolation

* Good, because the data model appears simpler at first.
* Bad, because business and technical concerns become coupled.
* Bad, because tenants with similar subscription plans but different isolation needs are harder to model.
