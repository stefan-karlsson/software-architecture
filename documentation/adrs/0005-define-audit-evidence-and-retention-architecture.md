# Define audit evidence and retention architecture

## Status

* Status: proposed

## Resolve how audit evidence is stored, retained, and protected

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The platform foundation requires auditability for memberships, grants, policy changes, production access, secret access, deployments, and billing or administration changes.
The architecture also integrates with an observability stack, but it does not yet define whether compliance-grade audit evidence is the same thing as operational telemetry.

The platform therefore still needs explicit decisions about:

* the system of record for audit evidence
* required retention behavior
* immutability and tamper-resistance expectations
* export and reporting expectations
* the boundary between audit evidence and general observability data

## Decision Drivers

* Compliance and governance expectations
* Traceable privileged activity
* Durable retention of regulated events
* Separation of evidence from convenience telemetry
* Support for later operational and security review

## Considered Options

* Use the observability stack as the only audit system of record
* Use a dedicated audit store and export selected signals to observability
* Use a mixed model with audit-grade storage plus operational summaries

## Decision Outcome

To be decided. This ADR exists to define the audit evidence architecture before implementation or compliance controls depend on implicit assumptions.

## Consequences

* Once decided, this ADR should drive updates to sections 5, 7, 10, and 11.
* The chosen model should define retention ownership, query/reporting expectations, and integrity guarantees.
