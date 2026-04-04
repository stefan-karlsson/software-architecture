# Select authoritative audit store and evidence export technology profile

## Status

* Status: proposed

## Choose the concrete technology profile behind authoritative audit evidence

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The accepted audit architecture requires a dedicated authoritative audit store, append-only evidence, retention enforcement, compensating records, and a clear boundary between authoritative evidence and observability exports.
What remains open is the concrete technology profile that will satisfy those requirements in a way that is queryable, durable, and operationally realistic.

Without a concrete decision, teams can still make materially different assumptions about:

* whether authoritative evidence lives in a relational store, a log broker, object storage, or an observability backend
* how append-only behavior and compensating records are enforced
* how observability exports are derived from authoritative evidence
* how retention, archival, and purge workflows are executed
* how durability and recovery expectations are met for privileged and regulated events

The platform therefore needs one proposed audit technology profile that can be validated against the accepted audit semantics.

## Decision Drivers

* Compliance-grade durability for authoritative evidence
* Clear separation between authoritative evidence and observability copies
* Efficient evidence retrieval for audit review and governance workflows
* Practical support for retention, archival, and purge enforcement
* Clear recovery behavior for failures and outages
* Compatibility with accepted audit, ownership, and runtime rules

## Considered Options

* Append-only relational audit store plus immutable object archive and observability export
* Log-broker-first evidence architecture with the event stream as the primary audit store
* Observability backend as the single audit and telemetry store

## Proposed Decision Direction

Leading option: "Append-only relational audit store plus immutable object archive and observability export", because it supports compliance-oriented queryability and retention control while keeping operational telemetry export clearly secondary to authoritative evidence.

### Proposed Audit Technology Profile

* Authoritative audit evidence is committed first to an append-only relational audit store optimized for indexed retrieval and governance queries.
* Immutable archival copies are written to object storage for long-term retention and recovery support.
* Observability tools receive derived audit and operational exports, for example through OpenTelemetry-based pipelines or equivalent structured export mechanisms.
* Corrections and enrichments remain modeled as linked follow-up records rather than in-place updates to authoritative evidence.
* Privileged and regulated actions should not be treated as successfully committed until the authoritative audit store has durably accepted the required evidence.

### Public Behavior Expected From This Direction

* Authoritative audit records must preserve stable event identifiers, timestamps, actor context, scope path, action type, decision or outcome, correlation identifiers, and retention metadata.
* Compliance review, evidence export, and retention enforcement read from the authoritative audit store and its archival path, not from observability tooling.
* Observability exports should preserve correlation identifiers back to authoritative evidence.
* Failure of the observability path must not invalidate already committed authoritative evidence.

### Questions To Resolve Before Acceptance

* Whether the authoritative relational store should be optimized primarily for transactional writes, evidence retrieval, or mixed workloads
* Which immutability controls are required for the archival object-storage layer
* Whether observability export is synchronous for a small critical subset of events or fully asynchronous after the authoritative write commits
* What recovery point and recovery time objectives apply to authoritative audit evidence

### Positive Consequences

* Authoritative evidence stays queryable, reviewable, and separate from operational telemetry.
* Long-term retention and archive handling become architecturally explicit.
* Observability outages no longer imply governance evidence loss.
* The accepted audit semantics gain a concrete implementation direction.

### Negative Consequences

* The platform must operate both authoritative evidence storage and export paths.
* Retention and archive workflows require stronger operational discipline than a telemetry-only approach.
* Concrete database and archival product choices still need a later acceptance decision.

### Non-Goals and Deferred Decisions

* This ADR does not choose a specific relational database product, object-storage vendor, or telemetry product.
* This ADR does not define the full audit schema for every event family.
* This ADR does not allow observability tooling to become the authoritative evidence store.
* This ADR does not require the archive layer to be the primary query interface for routine audit review.

## Consequences

* Section 7 should point to this ADR as the open concrete follow-on to the accepted logical audit architecture.
* Future platform design work should assume an authoritative evidence path plus derived export path rather than one shared telemetry sink.
* Any later proposal to use a log broker or observability backend as the sole audit system of record should explicitly challenge the accepted audit semantics and this proposed direction.

## Validation Questions

* Can authoritative evidence still be queried and retained correctly when the observability export path is unavailable?
* Can privileged actions fail closed when authoritative evidence cannot be durably accepted?
* Can retention enforcement and archival workflows operate from authoritative evidence rather than inferred telemetry?
* Can operators correlate observability signals back to authoritative audit records without treating the observability backend as the source of truth?

## Pros and Cons of the Options

### Append-only relational audit store plus immutable object archive and observability export

* Good, because it supports governance queries and evidence review directly.
* Good, because it keeps telemetry export secondary to authoritative evidence.
* Good, because it provides a natural place to implement retention and archive controls.
* Bad, because it introduces multiple persistence concerns instead of one single sink.

### Log-broker-first evidence architecture with the event stream as the primary audit store

* Good, because append-only semantics fit a streaming model naturally.
* Good, because downstream exports and projections are straightforward.
* Bad, because evidence retrieval, retention enforcement, and correction workflows can become awkward if the stream is the only authoritative read surface.
* Bad, because governance users may end up depending on operational streaming infrastructure for evidence access.

### Observability backend as the single audit and telemetry store

* Good, because it appears operationally simple at first glance.
* Bad, because it collapses authoritative evidence and telemetry into one mutable operational system.
* Bad, because retention and governance guarantees become hard to separate from troubleshooting-oriented data handling.
