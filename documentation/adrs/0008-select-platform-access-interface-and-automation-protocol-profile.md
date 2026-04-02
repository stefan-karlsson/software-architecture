# Select platform access interface and automation protocol profile

## Status

* Status: proposed

## Choose the external platform access shape for users and automation

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The platform foundation defines users, automation clients, service accounts, scoped authorization, policy evaluation, auditability, and hierarchy-aware operations.
The current architecture book intentionally leaves the concrete external interface and protocol profile open, which keeps the logical model clean but also leaves implementers without a stable public interaction model.

Without a concrete interface decision, teams can still make materially different assumptions about:

* whether human administration is browser-first, CLI-first, or API-first
* whether automation uses the same public interface as interactive administration
* whether the primary machine protocol is REST, GraphQL, or gRPC
* how long-running governed operations are exposed to clients
* how public interface design supports auditing, idempotency, and backward compatibility

The platform therefore needs one proposed external access profile that can be reviewed and either accepted or refined before implementation begins.

## Decision Drivers

* Predictable public interface shape for users and automation
* Simple interoperability for service-account-driven automation
* Good support for auditability, idempotency, and traceability
* Compatibility with the accepted authorization and policy model
* Low operational complexity for a first implementation
* Clear evolution path for later CLI and client tooling

## Considered Options

* Browser-based administrative UI plus versioned HTTPS JSON REST API as the primary public interface
* GraphQL-based public interface with generated clients for both UI and automation
* gRPC-first public interface for automation with a separate UI-specific backend

## Proposed Decision Direction

Leading option: "Browser-based administrative UI plus versioned HTTPS JSON REST API as the primary public interface", because it gives both humans and automation clients one interoperable and auditable access model without requiring protocol-specific tooling or a split public contract from the start.

### Proposed Interface Profile

* Human administration uses a browser-based platform foundation UI.
* Interactive and automation clients both use a versioned HTTPS JSON REST API as the primary public platform interface.
* The administrative UI acts as a client of the same public platform API rather than relying on a hidden second control API.
* Service-account-driven automation uses the same scope-aware API surface as interactive administration, subject to different credentials and policy outcomes.
* Long-running governed operations should be modeled as explicit job or operation resources rather than opaque fire-and-forget commands.

### Public Behavior Expected From This Direction

* Public requests should carry stable identifiers suitable for audit correlation and idempotency handling where applicable.
* Public resources should align to the accepted hierarchy and capability boundaries rather than exposing transport-specific shortcuts.
* Platform responses should make authorization failure, policy denial, validation failure, and asynchronous processing states distinguishable.
* The first implementation should avoid GraphQL- or gRPC-only public capabilities unless a later ADR justifies an additional interface profile.

### Questions To Resolve Before Acceptance

* Whether the first implementation should publish a supported CLI alongside the browser UI and public API
* How API versioning should be represented externally, for example URI versioning or media-type versioning
* Whether asynchronous notifications should use polling only in the first implementation or also include webhook support
* Which idempotency guarantees are mandatory for mutation operations such as grant changes, policy updates, and placement actions

### Positive Consequences

* Users and automation clients get one consistent public interaction model.
* The interface profile aligns well with the accepted audit and authorization semantics.
* Backward compatibility and documentation can focus on one primary public contract.
* A future CLI can be built on top of the same public API without inventing a second automation surface.

### Negative Consequences

* The public API must be designed carefully enough to serve both interactive and automation use cases.
* Some highly streaming or strongly typed automation scenarios may fit less naturally than in a gRPC-first design.
* The architecture still needs a follow-up credential and token decision to complete the trust story.

### Non-Goals and Deferred Decisions

* This ADR does not choose the identity federation or service-account credential model.
* This ADR does not define detailed resource schemas, pagination formats, or error payload structures.
* This ADR does not require a CLI in the first implementation.
* This ADR does not prohibit later internal use of other protocols between internal capability modules.

## Consequences

* Section 3 should stop treating the external interface as wholly unspecified and instead point to this proposed interface profile.
* Future API design work should align resources and operations to the accepted hierarchy, authorization, policy, and audit model.
* Any future proposal for GraphQL or gRPC as an additional public interface should justify why the REST profile is insufficient.

## Validation Questions

* Can a human administrator perform hierarchy, policy, and grant-management workflows through the same public API that automation clients use?
* Can service-account-driven automation invoke governed environment actions without requiring a second machine-only control protocol?
* Do long-running operations expose auditable job state rather than hiding asynchronous behavior behind immediate success responses?
* Does the proposed public interface make authorization denial and policy denial clearly distinguishable to clients?

## Pros and Cons of the Options

### Browser-based administrative UI plus versioned HTTPS JSON REST API as the primary public interface

* Good, because it gives humans and automation clients one broadly interoperable interface model.
* Good, because REST over HTTPS is easy to document, secure, and automate.
* Good, because it fits naturally with auditable request and resource semantics.
* Bad, because some streaming or strongly typed automation scenarios may require more design discipline.

### GraphQL-based public interface with generated clients for both UI and automation

* Good, because consumers can request shaped responses efficiently.
* Good, because one graph can serve many UI screens.
* Bad, because authorization, audit, and mutation semantics are often harder to keep explicit in operational governance APIs.
* Bad, because automation compatibility can become tightly coupled to schema and resolver design choices.

### gRPC-first public interface for automation with a separate UI-specific backend

* Good, because machine clients can get strong contracts and efficient transport.
* Good, because streaming scenarios are easier to model.
* Bad, because humans and automation would immediately diverge onto different public interaction models.
* Bad, because browser-first administration would still need an additional interface layer.
