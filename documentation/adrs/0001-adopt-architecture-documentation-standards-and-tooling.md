# Adopt architecture documentation standards and tooling

## Status

* Status: accepted

## Standardize architecture documentation approach for the SaaS Platform

* Deciders: Architecture Team
* Date: 2026-03-29

## Context and Problem Statement

Our architecture documentation needs to stay consistent, reviewable, and easy to evolve as the SaaS Platform grows.  
Without shared standards and tooling, documentation drifts in structure and quality and becomes difficult to maintain.

## Decision Drivers

* Consistent architecture structure across teams
* Documentation-as-code workflow in the same repository as implementation artifacts
* Ability to generate diagrams and publish documentation automatically
* Traceable architectural decisions over time

## Considered Options

* Use arc42 + C4 + docToolchain + Structurizr DSL + ADR/TDR records in this repository
* Use ad-hoc Markdown files and manually maintained images

## Decision Outcome

Chosen option: "Use arc42 + C4 + docToolchain + Structurizr DSL + ADR/TDR records in this repository", because it provides a structured, automatable, and version-controlled documentation baseline that fits our engineering workflow.

### Positive Consequences

* Architecture documentation has a defined chapter structure (arc42).
* C4 diagrams are generated from source (`workspace.dsl`) instead of being hand-drawn.
* CI/CD can build and publish docs reproducibly.
* ADRs and TDRs make key decisions and debt explicit and auditable.

### Negative Consequences

* Team members must learn and maintain the selected toolchain.
* Generated artifacts require periodic validation in CI.

## Pros and Cons of the Options

### Use arc42 + C4 + docToolchain + Structurizr DSL + ADR/TDR records

* Good, because the structure and conventions are explicit.
* Good, because diagrams and docs can be generated automatically.
* Bad, because it introduces tooling overhead.

### Use ad-hoc Markdown and manually maintained images

* Good, because startup effort is low.
* Bad, because documentation quality and consistency degrade over time.
* Bad, because manual diagrams are harder to keep in sync.
