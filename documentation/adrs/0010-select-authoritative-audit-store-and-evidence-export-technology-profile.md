# Select authoritative audit store and evidence export technology profile

## Status

* Status: accepted

## Choose the concrete technology profile behind the official audit record

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The accepted audit architecture requires a dedicated audit store that serves as the official record, append-only evidence, retention enforcement, compensating records, and a clear boundary between the official audit record and observability exports.
This ADR resolves the concrete technology profile that satisfies those requirements in a way that is queryable, durable, and operationally realistic.

Without a concrete decision, teams can still make materially different assumptions about:

* whether the official audit record lives in a relational store, a log broker, object storage, or an observability backend
* how append-only behavior and compensating records are enforced
* how observability exports are derived from the official audit record
* how retention, archival, and purge workflows are executed
* how durability and recovery expectations are met for privileged and regulated events

The platform therefore needs one accepted audit technology profile that implementations can validate against the accepted audit semantics.

## Decision Drivers

* Compliance-grade durability for the official audit record
* Clear separation between the official audit record and observability copies
* Efficient evidence retrieval for audit review and governance workflows
* Practical support for retention, archival, and purge enforcement
* Clear recovery behavior for failures and outages
* Compatibility with accepted audit, ownership, and runtime rules

## Considered Options

* Append-only relational audit store plus immutable object archive and observability export
* Log-broker-first evidence architecture with the event stream as the primary audit store
* Observability backend as the single audit and telemetry store

## Decision Outcome

Chosen option: "Append-only relational audit store plus immutable object archive and observability export", because it supports compliance-oriented queryability and retention control while keeping operational telemetry export clearly secondary to the official audit record.

### Normative Audit Technology Profile

* The official audit record is committed first to an append-only relational audit store optimized for indexed retrieval and governance queries.
* Immutable archival copies are written to object storage as the audit archive for long-term retention and recovery support.
* Observability tools receive derived audit and operational exports, for example through OpenTelemetry-based pipelines or equivalent structured export mechanisms.
* Corrections and enrichments remain modeled as linked follow-up records rather than in-place updates to the official audit record.
* Privileged and regulated actions are not treated as successfully committed until the official audit store has durably accepted the required evidence.

### Public Behavior Locked by This Decision

* Official audit records must preserve stable event identifiers, timestamps, actor context, scope path, action type, decision or outcome, correlation identifiers, and retention metadata.
* Compliance review, evidence export, and retention enforcement read from the official audit store and audit archive, not from observability tooling.
* Observability exports should preserve correlation identifiers back to the official audit record.
* Failure of the observability path must not invalidate an already committed official audit record.
* The audit archive supports long-term retention and recovery, but routine governance review continues to read from the official audit store.

### Positive Consequences

* The official audit record stays queryable, reviewable, and separate from operational telemetry.
* Long-term retention and archive handling become architecturally explicit.
* Observability outages no longer imply governance evidence loss.
* The accepted audit semantics gain a concrete implementation direction.

### Negative Consequences

* The platform must operate both official audit storage and export paths.
* Retention and archive workflows require stronger operational discipline than a telemetry-only approach.
* Concrete database and archival product choices still need a later acceptance decision.

### Non-Goals and Deferred Decisions

* This ADR does not choose a specific relational database product, object-storage vendor, or telemetry product.
* This ADR does not define the full audit schema for every event family.
* This ADR does not allow observability tooling to become the official audit store.
* This ADR does not require the archive layer to be the primary query interface for routine audit review.
* This ADR does not fix whether the relational store is tuned primarily for writes, evidence retrieval, or mixed workloads.
* This ADR does not fix the exact immutability controls for the object-storage archive layer.
* This ADR does not fix whether any small critical subset of observability exports must be synchronous after the official audit-store write commits.
* This ADR does not fix exact recovery point or recovery time objectives for the official audit record.

## Consequences

* Section 7 should describe this ADR as the accepted audit storage and export direction behind the logical audit architecture.
* Future platform design work should assume an official audit path plus derived export path rather than one shared telemetry sink.
* Any later proposal to use a log broker or observability backend as the sole audit system of record should explicitly challenge the accepted audit semantics and this accepted direction.

## Validation Scenarios

* The observability export path is unavailable while the official audit store remains available, and governed actions still complete with the official audit record preserved.
* A privileged action cannot durably commit the official audit record, and the platform does not report the action as successfully committed.
* Retention enforcement or evidence export runs from the official audit store and audit archive rather than inferred telemetry.
* An operator correlates an observability signal back to the official audit record through a shared correlation identifier without treating the observability backend as the source of truth.

## Pros and Cons of the Options

### Append-only relational audit store plus immutable object archive and observability export

* Good, because it supports governance queries and evidence review directly.
* Good, because it keeps telemetry export secondary to the official audit record.
* Good, because it provides a natural place to implement retention and archive controls.
* Bad, because it introduces multiple persistence concerns instead of one single sink.

### Log-broker-first evidence architecture with the event stream as the primary audit store

* Good, because append-only semantics fit a streaming model naturally.
* Good, because downstream exports and projections are straightforward.
* Bad, because evidence retrieval, retention enforcement, and correction workflows can become awkward if the stream is the only official read surface.
* Bad, because governance users may end up depending on operational streaming infrastructure for evidence access.

### Observability backend as the single audit and telemetry store

* Good, because it appears operationally simple at first glance.
* Bad, because it collapses the official audit record and telemetry into one mutable operational system.
* Bad, because retention and governance guarantees become hard to separate from troubleshooting-oriented data handling.
