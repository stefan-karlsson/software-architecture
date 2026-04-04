# Select authoritative state integration and projection technology profile

## Status

* Status: proposed

## Choose how owner-managed state changes propagate across capabilities

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The accepted ownership and consistency architecture requires authoritative write ownership per capability, local transactions within each owner boundary, durable asynchronous integration across capabilities, rebuildable projections, and authoritative owner reads when freshness matters.
What remains open is the concrete integration and projection technology profile that will make those rules practical and repeatable.

Without a concrete decision, teams can still make materially different assumptions about:

* whether owner-to-owner coordination is synchronous API chaining or durable event propagation
* how owner commits are connected to downstream change notifications
* how projections are populated, rebuilt, and replayed
* how consumers distinguish authoritative owner reads from eventually consistent views
* how replay, backfill, and lag handling work operationally

The platform therefore needs one proposed technology profile for state propagation and projections.

## Decision Drivers

* Durable cross-capability propagation after owner commits
* Recoverable projection rebuild and replay behavior
* Clear distinction between authoritative reads and convenience views
* Low risk of losing change notifications during owner updates
* Compatibility with accepted ownership, audit, and runtime models
* Practical support for future platform evolution

## Considered Options

* Transactional outbox plus durable message broker and consumer-owned projections
* Synchronous API chaining between capability owners for all dependent updates
* Shared database change-data-capture from a central platform store

## Proposed Decision Direction

Leading option: "Transactional outbox plus durable message broker and consumer-owned projections", because it matches the accepted owner-first consistency model, reduces dual-write risk, and gives downstream capabilities a recoverable projection path without turning projections into shared write authorities.

### Proposed Integration Profile

* Each authoritative capability commits its own authoritative state within its local transaction boundary.
* The same owner transaction records a durable outbox entry or equivalent change record for downstream propagation.
* A durable broker or stream distributes owner-originated change notifications to dependent capabilities.
* Consuming capabilities build and maintain their own projections, caches, or read models from those change notifications.
* Freshness-sensitive workflows continue to read from the owner directly instead of treating projections as real-time truth.

### Public Behavior Expected From This Direction

* Owner-originated change notifications must be durable enough to support retry and replay after downstream failures.
* Projections must remain rebuildable from authoritative state or from replayable change streams.
* Operational tooling should make lag, replay status, and projection health visible.
* A projection becoming stale or unavailable must not transfer write ownership away from the authoritative capability.

### Questions To Resolve Before Acceptance

* Which broker or stream technology best fits ordering, replay, and operational simplicity needs
* Whether some low-value derived views can be rebuilt on demand instead of continuously projected
* Which projection stores are capability-local versus shared read-only infrastructure
* How replay checkpoints, dead-letter handling, and recovery ownership should be operated

### Positive Consequences

* Owner-first change handling gets a clear implementation pattern.
* Dual-write risk is reduced compared with ad hoc synchronous propagation.
* Projections gain a credible rebuild and replay model.
* Cross-capability coupling stays lower than in synchronous orchestration chains.

### Negative Consequences

* Broker, replay, and lag management become explicit platform-operational concerns.
* Teams must handle eventual consistency and stale projections deliberately.
* Concrete message-broker and projection-store choices still need a later acceptance decision.

### Non-Goals and Deferred Decisions

* This ADR does not choose a vendor-specific broker, database, or cache product.
* This ADR does not eliminate the need for direct owner reads in freshness-sensitive flows.
* This ADR does not make projections authoritative.
* This ADR does not require every internal interaction to become event-driven when a direct owner read is simpler and freshness-critical.

## Consequences

* Sections 6, 7, and 8 should point to this ADR as the concrete follow-on to the accepted ownership model.
* Future persistence design should assume outbox-backed propagation and consumer-owned projections unless a later ADR justifies an exception.
* Any proposal for broad synchronous update chaining or projection-as-source-of-truth behavior should explicitly challenge the accepted ownership rules and this proposed direction.

## Validation Questions

* Can owner-managed records be committed without risking silent loss of downstream change notifications?
* Can lagging projections be rebuilt without reassigning ownership or blocking authoritative writes?
* Can consumers tell when they need an authoritative owner read instead of a derived view?
* Can downstream failures be retried or replayed without distributed rollback?

## Pros and Cons of the Options

### Transactional outbox plus durable message broker and consumer-owned projections

* Good, because it aligns well with owner-first commits and durable asynchronous propagation.
* Good, because it gives projections a replayable recovery path.
* Good, because it reduces dual-write risk compared with ad hoc change emission.
* Bad, because broker operations, replay, and lag visibility become first-class concerns.

### Synchronous API chaining between capability owners for all dependent updates

* Good, because the flow can appear easier to understand at first glance.
* Bad, because availability and latency coupling grow quickly across capabilities.
* Bad, because partial failure handling becomes brittle without really solving ownership concerns.

### Shared database change-data-capture from a central platform store

* Good, because downstream consumers can react to one shared change feed.
* Bad, because it pushes the architecture back toward a central shared write model that the accepted ownership ADR rejected.
* Bad, because capability ownership becomes weaker when integration depends on one common persistence substrate.
