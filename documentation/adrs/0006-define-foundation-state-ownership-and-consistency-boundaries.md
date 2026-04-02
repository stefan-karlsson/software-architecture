# Define foundation state ownership and consistency boundaries

## Status

* Status: proposed

## Resolve which capability owns which platform records

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The platform foundation describes clear capability modules, but it does not yet define where key records are owned and how changes to them are coordinated.
This affects principals, memberships, grants, roles, permissions, policies, subscriptions, runtime bindings, data boundaries, network boundaries, and audit records.

Without an explicit ownership and consistency model, teams can make incompatible decisions about:

* source-of-truth boundaries
* transactional expectations
* update ordering across capabilities
* recovery and reconciliation behavior
* read and write responsibilities

## Decision Drivers

* Clear data ownership
* Predictable change behavior
* Recovery and reconciliation strategy
* Reduced coupling between capability modules
* Better basis for persistence design

## Considered Options

* Centralize all governed state in one platform store
* Partition ownership by capability with explicit integration boundaries
* Use a hybrid model with authoritative domain stores plus derived read models

## Decision Outcome

To be decided. This ADR exists to define the foundation state model before persistence and integration behavior are implemented implicitly.

## Consequences

* Once decided, this ADR should drive updates to sections 5, 6, and 7.
* The chosen model should clarify which capability owns authoritative writes and how cross-capability consistency is achieved.
