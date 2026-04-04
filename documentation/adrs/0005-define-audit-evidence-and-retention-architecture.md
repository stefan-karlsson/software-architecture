# Define audit evidence and retention architecture

## Status

* Status: accepted

## Standardize how audit evidence is stored, retained, and protected

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The Platform Control Plane requires auditability for memberships, grants, policy changes, production access, secret access, deployments, and billing or administration changes.
The architecture also integrates with an observability stack, but operational telemetry is not automatically sufficient as compliance-grade audit evidence.

Without an explicit decision, teams could still implement materially different behavior for:

* the system of record for audit evidence
* the boundary between the official audit record and operational telemetry
* retention ownership and enforcement
* immutability and correction behavior
* export and reporting expectations for audit review
* commit guarantees for privileged or regulated actions

The platform therefore needs one normative audit evidence model that every implementation can follow.

## Decision Drivers

* Compliance and governance expectations
* Durable retention of regulated activity
* Traceable privileged actions across all scopes
* Clear separation between audit evidence and convenience telemetry
* Tamper resistance and evidence integrity
* Support for later operational, security, and compliance review

## Considered Options

* Use the observability stack as the only audit system of record
* Use a dedicated audit store and export selected signals to observability
* Use a mixed model with audit-grade storage plus operational summaries

## Decision Outcome

Chosen option: "Use a dedicated audit store and export selected signals to observability", because it keeps compliance-grade evidence durable in one official audit store while still supporting operational visibility through telemetry exports.

### Normative Audit Evidence Model

* The platform uses a dedicated audit store as the system of record for audit evidence.
* The observability stack receives selected audit signals and operational summaries, but it is not the official audit store.
* Audit evidence is append-only after commit.
* Committed audit records must not be overwritten in place.
* Corrections, reconciliations, or enrichment must be represented by linked follow-up records rather than mutation of original records.
* Canonical audit evidence must preserve actor, scope, action, decision, and outcome context.

### Normative Retention Model

* Audit retention is enforced by the official audit store according to the combined effective policy and mandatory platform baseline controls.
* Child scopes may tighten retention or add stricter handling requirements, but they must not weaken mandatory baseline retention requirements.
* Retention expiration, archival, and purge behavior must itself be governed and auditable.
* Audit review and retention enforcement must operate from the official audit record rather than observability copies.

### Normative Boundary Between Audit Evidence and Observability

* The audit store holds compliance-grade evidence.
* The observability stack holds exported or derived telemetry intended for operations, alerting, dashboards, and convenience analysis.
* Loss of observability copies must not imply loss of the official audit record.
* Observability data must not be treated as the only source for compliance review, retention enforcement, or governance evidence.
* Exported telemetry should preserve correlation identifiers that allow operators and auditors to trace operational signals back to the official audit record.

### Normative Commit and Integrity Rules

* Privileged or regulated actions must not be treated as successfully committed until the official audit record has been durably accepted by the audit architecture.
* Durable acceptance may be direct persistence to the audit store or platform-owned durable buffering under the audit architecture, but it must not rely on transient best-effort emission only.
* If the official audit record for a privileged or regulated mutation cannot be durably accepted, the platform must not report the mutation as successfully committed.
* The platform must preserve enough integrity context to distinguish original records, compensating records, exports, and later review artifacts.

### Normative Event Coverage

* Canonical audit evidence is mandatory for membership changes.
* Canonical audit evidence is mandatory for grant assignment and revocation.
* Canonical audit evidence is mandatory for policy changes and policy-driven decisions.
* Canonical audit evidence is mandatory for privileged authorization decisions and privileged access outcomes.
* Canonical audit evidence is mandatory for production access, secret access, deployments, and billing or administrative changes.
* Canonical audit evidence is mandatory for runtime, data, and network boundary changes when they affect governed environments.

### Public Behavior Locked by This Decision

* Official audit records must preserve at minimum: event identifier, event timestamp, actor identity, actor type, action or event type, target scope, scope path, decision or outcome, source capability, correlation identifier, and retention context.
* The capabilities that produce governed audit evidence include Identity and Access, Policy, Platform Hierarchy, and Environment Isolation.
* Audit review, compliance export, and governance evidence retrieval must read from the official audit store.
* Operational dashboards, alerts, and troubleshooting flows may read from observability exports.
* Export to observability may summarize or redact data for operational use, but it must not replace official audit retention.

### Positive Consequences

* Compliance-grade evidence has one official source.
* Retention enforcement becomes explicit and testable.
* Operators can use telemetry for day-to-day work without turning observability into the evidence source of truth.
* Audit correction and reconciliation stay traceable because original records are preserved.
* Privileged and regulated actions gain stronger integrity guarantees.

### Negative Consequences

* The platform must maintain a dedicated audit storage concern in addition to observability exports.
* Privileged workflows may need to fail or remain pending when the official audit record cannot be durably accepted.
* Teams must manage correlation between the official audit record and operational telemetry instead of assuming they are the same artifact.
* Concrete storage and archival technology choices still require later decisions.

### Non-Goals and Deferred Decisions

* This ADR does not choose a specific database, object store, or vendor technology for the audit store.
* This ADR does not define exact wire schemas for exports or reporting APIs.
* This ADR does not define cross-region replication strategy or concrete disaster-recovery mechanics.
* Any future requirement to weaken append-only behavior, rely on observability as the only source of evidence, or allow silent record mutation requires a follow-up ADR.

## Consequences

* Section 5 reflects that Audit Evidence owns the official audit record rather than only telemetry export.
* Section 7 keeps concrete storage technology open while describing the official audit store as a required architectural concern.
* Section 10 includes scenarios that distinguish official audit retention from observability exports and cover commit failure when the official audit record cannot be durably accepted.
* Section 11 treats missing official audit persistence as a material implementation risk until concrete storage choices are made.
* Implementations should add automated tests for the validation scenarios below before relying on local assumptions about audit durability or retention.

## Validation Scenarios

* A membership change creates an official audit record with actor, scope, action, and resulting effect context.
* A policy-driven denial, such as blocked secret access from an untrusted network, creates an official audit record that preserves permission context, policy outcome, and final decision.
* A production deployment approval flow records request, approval decision, execution outcome, and relevant scope chain.
* Effective policy requires 365-day retention, and the official audit store preserves the evidence for that duration.
* A child scope attempts to reduce retention below a mandatory baseline requirement, and the platform rejects or ignores the weakening while preserving the stronger retention rule.
* The observability stack is unavailable while the official audit store is available, and governed actions can still complete with the official audit record preserved.
* Canonical audit evidence for a privileged mutation cannot be durably accepted, and the platform does not report that mutation as successfully committed.
* An audit record needs correction, and the platform writes a compensating or linked follow-up record instead of mutating the original record in place.
* An operator correlates an observability event back to the official audit record through a shared correlation identifier.

## Pros and Cons of the Options

### Use the observability stack as the only audit system of record

* Good, because the architecture appears simpler at first.
* Bad, because operational telemetry and compliance evidence become conflated.
* Bad, because retention, integrity, and evidence review guarantees become harder to define and test.

### Use a dedicated audit store and export selected signals to observability

* Good, because the official audit record remains durable and trustworthy.
* Good, because telemetry can still support operations and alerting.
* Good, because retention and immutability rules can be enforced at the evidence source of truth.
* Bad, because the platform must operate both official audit storage and telemetry export flows.

### Use a mixed model with audit-grade storage plus operational summaries

* Good, because it acknowledges different audiences and use cases.
* Bad, because without a clear source-of-truth rule it can still become ambiguous which records are official.
* Bad, because teams may implement incompatible boundaries unless the dedicated audit store remains explicitly the system of record.
