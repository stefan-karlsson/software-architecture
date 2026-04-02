# Adopt hierarchical scope and inheritance model

## Status

* Status: accepted

## Standardize the platform hierarchy and inheritance rules

* Deciders: Architecture Team
* Date: 2026-04-02

## Context and Problem Statement

The platform needs one consistent way to reason about scope, access, policy, audit context, and defaults.
Without a shared hierarchy, different teams would likely invent incompatible models for tenant, workspace, service, and environment governance.

## Decision Drivers

* Consistent scope model across the platform
* Fine-grained authorization with reusable roles
* Explicit policy inheritance from platform to environment
* Auditable privileged and regulated activity at every scope
* Ability to evolve the platform without introducing parallel hierarchies

## Considered Options

* Adopt one hierarchical scope model with downward inheritance
* Allow different hierarchies for different product or isolation models

## Decision Outcome

Chosen option: "Adopt one hierarchical scope model with downward inheritance", because it creates a single architecture for access, policy, audit, and defaults.

### Positive Consequences

* The platform has one canonical hierarchy: Platform, Tenant, Workspace, Project / Service, Environment.
* Grants can be scoped consistently to tenant, workspace, project / service, or environment.
* Policy, audit context, and defaults can inherit downward in a predictable way.
* Shared, silo, and hybrid tenants can use the same business hierarchy.

### Negative Consequences

* Teams must align new capabilities to the shared hierarchy instead of inventing local models.
* Inheritance semantics must be implemented carefully to avoid accidental weakening of controls.

## Pros and Cons of the Options

### Adopt one hierarchical scope model with downward inheritance

* Good, because governance remains consistent across all scopes.
* Good, because authorization and policy reasoning become more predictable.
* Bad, because the hierarchy becomes a foundational architectural constraint.

### Allow different hierarchies for different product or isolation models

* Good, because local teams could optimize for narrow use cases.
* Bad, because audit, policy, and authorization semantics would fragment.
* Bad, because shared and silo tenants would no longer look identical in the domain.
