# Define hybrid isolation resolution rules

## Status

* Status: accepted

## Standardize how hybrid isolation is resolved and constrained

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The platform foundation supports shared, silo, and hybrid isolation through isolation profile plus runtime, data, and network boundaries.
Hybrid is intentionally first-class, but the architecture still needs explicit rules for how placement is resolved when subscription defaults, inherited policy, and environment-specific tightening all apply.

Without an explicit decision, teams could still implement materially different behavior for:

* whether runtime, data, and network boundaries may diverge independently
* whether environment-level resolution may tighten subscription defaults
* which policy constraints are evaluated before placement is accepted
* how hybrid outcomes are represented for audit and operational review
* how subscription defaults differ from final environment-specific placement decisions

The platform therefore needs one normative hybrid-isolation model that every implementation can follow.

## Decision Drivers

* Predictable placement behavior
* Clear relationship between subscription plan, isolation profile, and policy
* Testable hybrid behavior
* Reduced ambiguity for platform operators and service teams
* Clear auditability of placement decisions and boundary changes
* Consistent treatment of tightening versus weakening across the hierarchy

## Considered Options

* Resolve all boundaries together from one shared isolation decision
* Resolve runtime, data, and network boundaries independently under a common policy envelope
* Restrict hybrid behavior to predefined patterns only

## Decision Outcome

Chosen option: "Resolve runtime, data, and network boundaries independently under a common policy envelope", because it keeps hybrid isolation flexible enough for real workloads while preserving one consistent validation model for policy, inheritance, and audit.

### Normative Precedence Model

* The subscription isolation profile defines the default isolation intent for the tenant.
* Environment-specific resolution may tighten that default for a specific environment.
* Effective policy is then evaluated and may further constrain or reject the candidate boundaries.
* Final placement is accepted only if all resolved boundaries comply with effective policy and do not weaken the subscription default.

### Normative Boundary-Resolution Model

* Runtime binding, data boundary, and network boundary are resolved separately.
* In hybrid mode, those three boundaries may diverge from one another in the final result.
* Boundary divergence is valid only when each resolved boundary remains compliant with inherited policy and with the anti-weakening rule.
* Independent resolution does not change the business hierarchy or the meaning of tenant, workspace, project / service, and environment scopes.

### Normative Tightening Rule

* Environment-level resolution may move from shared behavior toward dedicated behavior.
* Environment-level resolution may not relax a stricter subscription default.
* Child scopes may tighten placement and isolation constraints, but they must not weaken mandatory parent controls.
* A silo-oriented default remains dedicated unless a later architectural decision explicitly changes that rule.

### Normative Policy Gate

* Policy constraints relevant to placement are evaluated before final placement is accepted.
* Relevant policy may constrain approved regions, trusted-network requirements, mandatory dedicated boundaries, retention-related constraints, or other mandatory parent controls that affect hosting or access posture.
* If any resolved boundary violates effective policy, placement must be denied or re-resolved before acceptance.
* Policy validation applies to each resolved boundary and to the final combined placement outcome.

### Normative Audit and Operability Rules

* Final boundary decisions must be recorded as canonical audit evidence.
* Boundary changes must be recorded as canonical audit evidence.
* Policy-driven placement denials must be recorded as canonical audit evidence.
* Operational views may consume exported telemetry, but the authoritative record of hybrid resolution remains in Audit and Governance.
* Audit context for hybrid resolution must preserve environment identity, subscription context, resolved runtime binding, resolved data boundary, resolved network boundary, applicable policy constraints, and final outcome.

### Public Behavior Locked by This Decision

* Isolation input must include the environment identity and scope path, parent subscription context, subscription plan, isolation profile, and the inherited effective policy relevant to placement.
* Isolation output must include the resolved runtime binding, resolved data boundary, resolved network boundary, placement accepted or denied, and decision context suitable for audit and operations.
* Subscription plan remains separate from isolation profile.
* Hierarchy records remain separate from resolved isolation records.
* Resolved boundaries remain separate from observability exports and audit projections.

### Positive Consequences

* Hybrid isolation remains expressive enough to support environment-specific hardening without a second business model.
* Runtime, data, and network isolation can evolve independently while still following one validation model.
* Placement behavior becomes auditable and easier to reason about during reviews and incident analysis.
* Subscription defaults remain meaningful because environment-level logic can tighten them but not silently weaken them.

### Negative Consequences

* Teams must reason about three related but separately resolved boundaries instead of one single placement field.
* Hybrid outcomes can be more varied and therefore require stronger validation and review tooling.
* Policy evaluation for placement becomes a first-class concern rather than a secondary afterthought.
* Concrete infrastructure mapping still requires later decisions.

### Non-Goals and Deferred Decisions

* This ADR does not require runtime, data, and network boundaries to always move together.
* This ADR does not allow environment-level weakening of subscription defaults.
* This ADR does not restrict hybrid behavior to a short list of hardcoded combinations in the first implementation.
* This ADR does not choose concrete hosting, storage, networking, or cloud technologies.
* Any future need for named hybrid packages or stricter allowed-combination catalogs requires a follow-up ADR rather than local implementation rules.

## Consequences

* Section 6 describes isolation resolution as independent boundary selection under one policy envelope.
* Section 7 explains that hybrid placement may resolve mixed boundaries while still enforcing anti-weakening rules and policy validation.
* Section 10 includes scenarios that cover mixed-boundary hybrid results, policy-driven placement denial, and attempts to weaken stricter defaults.
* Implementations should add automated tests for the validation scenarios below before relying on local assumptions about hybrid placement behavior.

## Validation Scenarios

* A hybrid tenant with shared subscription defaults resolves a production environment to dedicated runtime, dedicated data, and dedicated network because environment-level tightening and policy allow it.
* A hybrid tenant resolves mixed boundaries, such as dedicated runtime with shared data and dedicated network, and the placement is accepted because all three boundaries satisfy the common policy envelope.
* An environment attempts to relax a stricter subscription default, such as moving from dedicated network to shared network, and the platform rejects the weakening.
* Policy restricts data storage to approved regions, and placement is denied when the candidate runtime or data boundary would violate that policy.
* Policy requires dedicated network isolation for production, and the platform rejects a hybrid result that leaves the network boundary shared even if runtime or data became dedicated.
* A silo subscription default remains dedicated across all environments because environment-level rules cannot weaken it.
* A boundary change for a governed environment is accepted and recorded with subscription context, resolved boundaries, policy inputs, and final outcome.
* A placement decision is denied by policy and the denial is auditable and visible in operational telemetry through exported signals.

## Pros and Cons of the Options

### Resolve all boundaries together from one shared isolation decision

* Good, because the final placement model appears simpler at first glance.
* Bad, because it makes hybrid cases harder to express cleanly.
* Bad, because runtime, data, and network concerns become unnecessarily coupled.

### Resolve runtime, data, and network boundaries independently under a common policy envelope

* Good, because hybrid placement stays expressive without changing the business hierarchy.
* Good, because each boundary can be validated explicitly against policy and default constraints.
* Good, because mixed boundary outcomes can still be made auditable and reviewable.
* Bad, because the model requires stronger validation and clearer operational visibility.

### Restrict hybrid behavior to predefined patterns only

* Good, because allowed combinations are easier to enumerate.
* Bad, because the platform becomes less flexible for legitimate workload-specific isolation needs.
* Bad, because teams may start creating exceptions outside the documented model when predefined patterns are too rigid.
