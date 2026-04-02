# Define foundation state ownership and consistency boundaries

## Status

* Status: proposed

## Standardize authoritative ownership and cross-capability consistency

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The platform foundation describes clear capability modules, but it does not yet define where key records are authoritatively owned and how changes to them are coordinated across capabilities.
This affects principals, memberships, grants, roles, permissions, policies, subscriptions, runtime bindings, data boundaries, network boundaries, and audit records.

Without an explicit ownership and consistency model, teams could still implement materially different behavior for:

* source-of-truth boundaries
* transactional expectations
* durable integration between capabilities
* update ordering and reconciliation behavior
* read and write responsibilities
* freshness expectations for owner reads versus projected reads

The platform therefore needs one normative state-ownership and consistency model that every implementation can follow.

## Decision Drivers

* Clear authoritative ownership for governed records
* Predictable change behavior across capability boundaries
* Reduced coupling between capability modules
* Recoverable downstream synchronization
* Better basis for persistence design and future implementation ADRs
* Clear separation between authoritative writes and convenience projections

## Considered Options

* Centralize all governed state in one platform store
* Partition ownership by capability with explicit integration boundaries
* Use a hybrid model with authoritative domain stores plus derived read models

## Decision Outcome

Chosen option: "Use a hybrid model with authoritative domain stores plus derived read models", because it preserves clear ownership per capability while still allowing read-optimized or cross-capability views without collapsing the platform into one shared write authority.

### Normative Ownership Model

* Each governed record type has exactly one authoritative write owner.
* Authoritative writes stay within the owning capability boundary.
* Non-owning capabilities may maintain projections, caches, or read models, but those copies are never authoritative.
* Derived read models may span capability boundaries, but they do not change the underlying source-of-truth assignment.

### Normative Ownership Map

* The Identity Provider is authoritative for external identity claims used for authentication.
* Identity and Access is authoritative for platform-specific principal records, service accounts, groups, memberships, grants, roles, and permissions.
* Tenant Hierarchy and Scope Management is authoritative for tenants, billing accounts, subscriptions, workspaces, projects / services, and environments.
* Policy Management is authoritative for platform baseline policy plus tenant, workspace, project / service, and environment policies, together with the source inputs required to compute effective policy.
* Isolation and Placement is authoritative for runtime bindings, data boundaries, network boundaries, and resolved placement state.
* Audit and Governance is authoritative for canonical audit evidence and retention-governed audit records.

### Normative Read and Write Rules

* Writes go only to the owning capability.
* Non-owning capabilities must not perform authoritative writes for another capability's records.
* Cross-capability workflows may read owner-managed records directly or consume projections of those records.
* If a workflow requires the freshest value, it must read from the owner rather than rely on a derived read model.
* Owner reads are authoritative. Projected reads may lag and must be treated accordingly in implementation and operations.

### Normative Consistency Model

* Each owner may use local transactions only within its own authoritative boundary.
* Cross-capability changes are coordinated through durable asynchronous integration rather than distributed transactions.
* An owning capability commits canonical state first and then emits durable change notifications or equivalent durable integration events for dependent capabilities.
* Downstream capabilities update their own derived state asynchronously based on the owner-originated change signal.
* Eventual consistency across capabilities is acceptable by default when authoritative ownership remains clear.

### Normative Recovery and Reconciliation Rules

* Derived read models must be rebuildable from authoritative state or durable owner-originated change streams.
* Failed downstream updates must be retried or reconciled without reassigning ownership to a consumer or projection.
* Recovery logic must preserve the authoritative owner of each record type even when projections are stale or temporarily unavailable.
* Audit evidence remains authoritative in Audit and Governance even if operational projections or observability exports lag behind.

### Public Behavior Locked by This Decision

* Every governed record category must have one explicit authoritative owner.
* External identity claims and platform access metadata are distinct ownership domains.
* Hierarchy and subscription records remain distinct from resolved isolation records.
* Scoped policy records remain distinct from runtime effective-policy evaluations and downstream policy-aware decisions.
* Canonical audit evidence remains distinct from observability exports, caches, or convenience projections.
* Owning capabilities must expose a durable integration mechanism for record changes that downstream capabilities depend on.

### Positive Consequences

* Capabilities can evolve internally without collapsing into one shared write model.
* Read-optimized views are still possible without confusing them with authoritative state.
* Cross-capability workflows become easier to recover because owner state is committed before downstream propagation.
* Freshness-sensitive workflows have a clear rule: read the owner.
* Persistence and recovery planning gain a stable ownership map for future implementation decisions.

### Negative Consequences

* Teams must manage asynchronous propagation and reconciliation instead of assuming instant global consistency.
* Projections can lag behind owner state and therefore require explicit freshness handling.
* Implementations must provide durable owner-originated change notifications rather than relying on ad hoc synchronous chaining.
* Concrete storage and transport choices still require later decisions.

### Non-Goals and Deferred Decisions

* This ADR does not choose specific databases, message brokers, caches, or wire formats.
* This ADR does not make distributed transactions the default consistency mechanism.
* This ADR does not allow one shared platform store to become the universal write authority for all governed state.
* This ADR does not allow ownership to move based on which capability reads a record most often.
* This ADR does not allow derived read models to become write authorities.

## Consequences

* Section 5 should reflect the authoritative ownership map across the capability modules.
* Section 6 should describe cross-capability flows as owner-first commits followed by asynchronous propagation and reconciliation where applicable.
* Section 7 should keep concrete persistence technologies open while describing authoritative stores and derived read models as distinct architectural concerns.
* Future implementation ADRs should choose concrete persistence and integration technologies without changing the ownership model defined here.
* Implementations should add automated tests for the validation scenarios below before relying on local assumptions about cross-capability state behavior.

## Validation Scenarios

* A membership change is written only by Identity and Access and later becomes visible in downstream read models through asynchronous propagation.
* A tenant or environment rename is written only by Tenant Hierarchy and Scope Management and is later reflected in authorization and audit projections without changing ownership.
* A policy update is committed by Policy Management and later changes authorization outcomes after downstream refresh or direct owner read.
* A runtime binding change is committed by Isolation and Placement while Tenant Hierarchy and Scope Management remains authoritative for the environment it belongs to.
* An authorization decision needs the freshest membership or grant data and therefore reads from Identity and Access instead of a potentially stale projection.
* A derived read model falls behind or is rebuilt, and authoritative writes remain available because ownership did not move to the projection.
* A cross-capability integration fails after the owner commits state, and retry plus reconciliation restore downstream consistency without distributed rollback.
* Canonical audit evidence remains authoritative in Audit and Governance even if observability exports or convenience projections are delayed.

## Pros and Cons of the Options

### Centralize all governed state in one platform store

* Good, because the platform appears simpler at first glance.
* Bad, because capability boundaries and ownership become weaker over time.
* Bad, because local changes in one area can couple unrelated domains into one shared write model.

### Partition ownership by capability with explicit integration boundaries

* Good, because ownership stays clear.
* Good, because capabilities can evolve more independently.
* Bad, because without derived read models cross-capability queries can become overly chatty or tightly coupled.

### Use a hybrid model with authoritative domain stores plus derived read models

* Good, because ownership remains clear while still supporting read-optimized and cross-capability views.
* Good, because authoritative writes and convenience reads stay distinct.
* Good, because downstream projections can be rebuilt without changing the source of truth.
* Bad, because teams must handle eventual consistency and projection lag explicitly.
