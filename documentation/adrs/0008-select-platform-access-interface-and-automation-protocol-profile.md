# Select platform access interface and automation protocol profile

## Status

* Status: accepted

## Choose the external platform access shape for users and automation

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The Platform Control Plane defines users, automation clients, service accounts, scoped authorization, policy evaluation, auditability, and hierarchy-aware operations.
The current architecture book defines the shared governance model, but without a concrete external interface and protocol profile implementers still lack a stable public interaction model.

Without a concrete interface decision, teams can still make materially different assumptions about:

* whether human administration is browser-first, CLI-first, or API-first
* whether automation uses the same public interface as interactive administration
* whether the primary machine protocol is REST, GraphQL, or gRPC
* how long-running governed operations are exposed to clients
* how public interface design supports auditing, idempotency, and backward compatibility

The platform therefore needs one accepted external access profile that implementation and later API design can build on.

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

## Decision Outcome

Chosen option: "Browser-based administrative UI plus versioned HTTPS JSON REST API as the primary public interface", because it gives both humans and automation clients one interoperable and auditable access model without requiring protocol-specific tooling or a split public contract from the start.

### Normative Interface Profile

* Human administration uses in-scope browser containers of the Platform Control Plane.
* Those browser containers follow [ADR 0013](./0013-adopt-multi-surface-browser-architecture-with-thin-shells-remotes-and-shared-browser-foundations.md) for accepted browser-surface responsibilities, thin shells, shared browser foundations, and remote-based capability delivery.
* Interactive and automation clients both use a versioned HTTPS JSON REST API as the primary public platform interface.
* The browser containers act as clients of the same public Platform Governance API rather than relying on a hidden second control API.
* Service-account-driven automation uses the same scope-aware API surface as interactive administration, subject to different credentials and policy outcomes.
* The accepted baseline does not introduce a separate machine-only public protocol for automation.
* Long-running governed operations should be modeled as explicit job or operation resources rather than opaque fire-and-forget commands.

### Public Behavior Locked by This Decision

* Public requests should carry stable identifiers suitable for audit correlation and idempotency handling where applicable.
* Public resources should align to the accepted hierarchy and capability boundaries rather than exposing transport-specific shortcuts.
* Platform responses should make authorization failure, policy denial, validation failure, and asynchronous processing states distinguishable.
* The first implementation should avoid GraphQL- or gRPC-only public capabilities unless a later ADR justifies an additional interface profile.

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
* This ADR does not define the internal browser-application composition model beyond depending on [ADR 0013](./0013-adopt-multi-surface-browser-architecture-with-thin-shells-remotes-and-shared-browser-foundations.md).
* This ADR does not define detailed resource schemas, pagination formats, or error payload structures.
* This ADR does not require a CLI in the first implementation.
* This ADR does not choose whether the first implementation should publish a supported CLI alongside the browser UI and public API.
* This ADR does not choose the exact external API versioning style, for example URI versioning or media-type versioning.
* This ADR does not choose whether asynchronous notifications use polling only in the first implementation or also include webhook support.
* This ADR does not choose detailed idempotency guarantees for mutation operations such as grant changes, policy updates, and placement actions.
* This ADR does not prohibit later internal use of other protocols between internal capability modules.

## Consequences

* Section 3 should stop treating the external interface as open and instead point to this accepted interface profile.
* Browser UI implementation and cross-team browser scaling should follow [ADR 0013](./0013-adopt-multi-surface-browser-architecture-with-thin-shells-remotes-and-shared-browser-foundations.md) instead of being reinvented inside individual feature teams or browser surfaces.
* Future API design work should align resources and operations to the accepted hierarchy, authorization, policy, and audit model.
* Any future proposal for GraphQL or gRPC as an additional public interface should justify why the REST profile is insufficient.

## Validation Scenarios

* A human administrator performs hierarchy, policy, and grant-management workflows through browser surfaces that act as clients of the shared public Platform Governance API.
* Service-account-driven automation invokes governed environment actions through the same public REST API without requiring a second machine-only control protocol.
* A long-running governed operation exposes auditable job or operation state instead of hiding asynchronous behavior behind an immediate success response.
* A client receives distinguishable responses for authorization denial, policy denial, validation failure, and asynchronous processing state.

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
