# Select runtime topology and network isolation implementation profile

## Status

* Status: proposed

## Choose the concrete hosting profile for shared, silo, and hybrid isolation

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The accepted isolation architecture defines shared, silo, and hybrid profiles, independent runtime, data, and network boundary resolution, anti-weakening rules, and policy-gated placement.
What remains open is the concrete runtime topology and network-isolation implementation profile that turns those logical rules into an operational hosting model.

Without a concrete decision, teams can still make materially different assumptions about:

* whether workloads run in one shared runtime estate, separate cells, or fully duplicated per-tenant stacks
* how silo and hybrid dedicated boundaries map to accounts, subscriptions, or network segments
* how dedicated data and network boundaries relate to shared runtime infrastructure
* how regional placement and ingress or egress boundaries are enforced
* how the same business hierarchy is preserved across materially different technical placements

The platform therefore needs one proposed implementation profile for runtime topology and network isolation.

## Decision Drivers

* Clear operational mapping from logical isolation outcomes to concrete hosting
* Strong enough isolation for shared, silo, and hybrid workloads
* Compatibility with environment-level tightening and anti-weakening rules
* Practical cost and operability balance across mixed tenant needs
* Alignment with accepted audit, policy, and ownership decisions
* Clear basis for future deployment and platform-engineering work

## Considered Options

* Cell-based runtime topology with shared cells, dedicated cells, and dedicated network segments selected by isolation outcome
* One shared runtime estate with namespace-only isolation for all profiles
* Full per-tenant stack duplication for every tenant regardless of profile

## Proposed Decision Direction

Leading option: "Cell-based runtime topology with shared cells, dedicated cells, and dedicated network segments selected by isolation outcome", because it can support shared, silo, and hybrid placement without forcing either one universal shared estate or universal per-tenant duplication.

### Proposed Hosting Profile

* The platform runs workloads in a cell-based topology rather than one monolithic shared runtime estate.
* Shared-profile environments use shared runtime cells, shared data services where allowed, and shared network boundaries.
* Silo-profile environments use dedicated runtime cells, dedicated data services, and dedicated network segments or accounts.
* Hybrid-profile environments may resolve each environment to shared or dedicated runtime, data, and network boundaries independently, but only within the accepted policy and anti-weakening rules.
* Dedicated network isolation should map to dedicated network segments and, where required, dedicated infrastructure accounts or subscriptions rather than namespace-only separation.

### Public Behavior Expected From This Direction

* Placement outputs must identify the runtime cell, data boundary class, and network boundary class selected for each governed environment.
* Mixed hybrid outcomes remain valid when they are policy-compliant and do not weaken stricter subscription defaults.
* The same tenant, workspace, workload, and environment hierarchy remains intact regardless of whether the final technical placement is shared or dedicated.
* Placement changes and denials remain authoritative audit events.

### Questions To Resolve Before Acceptance

* Which workload orchestrator and compute substrate best fit the cell model
* How many regions or regional cells are required in the first implementation
* Which data-service patterns support shared partitions versus dedicated stores
* How ingress, egress, and private connectivity should be modeled for dedicated network boundaries

### Positive Consequences

* Shared, silo, and hybrid outcomes gain a concrete operational mapping.
* The platform can offer dedicated boundaries where needed without duplicating everything for every tenant.
* Hybrid placement remains compatible with the accepted independent-boundary model.
* Network isolation becomes stronger than a namespace-only convention.

### Negative Consequences

* Platform engineering must operate shared and dedicated placement modes together.
* Cell sizing, regional topology, and dedicated-capacity management become real operational design concerns.
* Concrete orchestrator, data-service, and network-product choices still need a later acceptance decision.

### Non-Goals and Deferred Decisions

* This ADR does not choose a cloud vendor, orchestrator product, or network product.
* This ADR does not require every tenant to receive a fully dedicated stack.
* This ADR does not allow hybrid placement to change the business hierarchy.
* This ADR does not define the full region or disaster-recovery topology.

## Consequences

* Section 7 should point to this ADR as the concrete infrastructure follow-on to the accepted logical isolation model.
* Future platform-engineering work should assume a cell-based hosting pattern instead of either one universal shared estate or universal per-tenant duplication.
* Any later proposal to use namespace-only isolation for dedicated network outcomes should explicitly challenge the accepted isolation semantics and this proposed direction.

## Validation Questions

* Can the topology support shared, silo, and hybrid placements without changing the business hierarchy?
* Can dedicated network outcomes be implemented with stronger boundaries than namespace-only separation?
* Can a hybrid environment receive a dedicated network and runtime boundary while another environment under the same tenant remains shared?
* Can placement decisions remain auditable and policy-gated across both shared and dedicated cells?

## Pros and Cons of the Options

### Cell-based runtime topology with shared cells, dedicated cells, and dedicated network segments selected by isolation outcome

* Good, because it maps naturally to shared, silo, and hybrid isolation outcomes.
* Good, because it avoids both one universal shared estate and universal full duplication.
* Good, because it gives dedicated outcomes stronger technical boundaries than namespace-only isolation.
* Bad, because cell operations and capacity planning become explicit platform concerns.

### One shared runtime estate with namespace-only isolation for all profiles

* Good, because it appears operationally simple at first glance.
* Bad, because silo and dedicated hybrid outcomes become weak or misleading.
* Bad, because namespace-only isolation does not align well with stronger dedicated network expectations.

### Full per-tenant stack duplication for every tenant regardless of profile

* Good, because technical isolation is easy to reason about.
* Bad, because cost and operability become disproportionate for shared-profile tenants.
* Bad, because the architecture would lose much of the benefit of having separate shared, hybrid, and silo profiles.
