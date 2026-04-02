# Define effective-access evaluation semantics

## Status

* Status: accepted

## Standardize how effective access is resolved across scopes

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The platform foundation defines the authorization chain as `Principal -> Membership -> Grant -> Role -> Permission -> Scope`.
That model establishes the core building blocks, but it is not sufficient on its own to guarantee consistent implementation.

Without an explicit decision, teams could still implement materially different behavior for:

* how direct grants and group-derived grants combine
* how broader-scope grants apply to descendant scopes
* whether authorization supports explicit deny semantics
* how access resolution is separated from policy evaluation
* which decision context must be captured for audit

The platform therefore needs one normative effective-access model that every implementation can follow.

## Decision Drivers

* Consistent authorization behavior across all platform capabilities
* Least-privilege enforcement with default deny
* Predictable scope resolution across the hierarchy
* Clear separation between authorization and policy
* Testable allow and deny behavior
* Auditable authorization decisions

## Considered Options

* Resolve access through additive grants only, with policy handling all denials and restrictions
* Support additive grants plus explicit deny semantics
* Resolve access by nearest-scope precedence only

## Decision Outcome

Chosen option: "Resolve access through additive grants only, with policy handling all denials and restrictions", because it keeps authorization semantics predictable, preserves default deny, and keeps restrictive rules in the policy layer where the architecture already places them.

### Normative Authorization Model

* Authorization uses default deny.
* An action is eligible for authorization only if at least one matching grant expands to the required permission at the requested scope or one of its ancestor scopes.
* Effective permissions are the union of all matching direct and group-derived grants.
* The authorization layer does not support explicit deny grants.
* Policy evaluation happens only after permission resolution and can still deny an otherwise authorized action.

### Normative Scope-Matching Rules

* A tenant-scoped grant applies to that tenant and all descendant workspaces, projects / services, and environments.
* A workspace-scoped grant applies to that workspace and all descendant projects / services and environments.
* A project / service-scoped grant applies to that project / service and all descendant environments.
* An environment-scoped grant applies only to that environment.
* Access propagation is interpreted through the hierarchy during evaluation. Grants are not copied to child scopes.

### Normative Group Rules

* Groups aggregate principals for access management.
* Users and service accounts may be members of groups.
* Groups do not contain other groups in the first implementation.
* Group-derived grants are evaluated the same way as direct grants once group membership has been resolved.

### Effective-Access Evaluation Algorithm

1. Resolve the acting principal.
2. Resolve direct memberships for the principal at the relevant scopes.
3. Resolve flat group memberships for the principal.
4. Collect direct grants and group-derived grants whose scopes match the requested scope or one of its ancestor scopes.
5. Expand the roles from those grants into permissions.
6. Union the resulting permissions into one effective permission set.
7. If the required permission is absent, deny the action and audit the denied result.
8. If the required permission is present, evaluate effective policy for the requested action and scope.
9. If policy denies the action, deny it and audit the policy-driven denial with policy context.
10. If policy allows the action, allow it and audit the successful decision.

### Public Behavior Locked by This Decision

* Authorization input must include the acting principal, the requested permission, and the requested scope.
* Authorization output must include allow or deny plus enough decision context for audit and later review.
* Valid grant scopes remain limited to tenant, workspace, project / service, and environment.
* Authorization answers whether a valid matching grant provides the required permission at the requested scope.
* Policy answers whether the action is still allowed under inherited rules after permission resolution.
* Every authorization decision must preserve principal, resolved scope, matching grants or absence of grants, resolved permission, policy outcome when evaluated, and final allow or deny result.

### Positive Consequences

* Teams have one consistent effective-access model across the platform.
* Direct and group-derived access remains understandable because both use additive union semantics.
* Default deny remains simple: missing permission means denied access.
* Restrictive controls such as MFA, approval, trusted-network checks, or region rules stay in the policy layer.
* Audit records can capture a clear sequence from permission resolution to policy outcome to final decision.

### Negative Consequences

* The platform cannot express authorization-layer deny exceptions in the first implementation.
* Group support stays intentionally limited because nested groups are not supported.
* Broader-scope grants must be designed carefully to avoid over-entitlement.
* Teams that want custom precedence or propagation behavior must propose a new ADR instead of adding local rules.

### Non-Goals and Deferred Decisions

* No explicit deny grants are supported.
* No nested groups are supported.
* No nearest-scope-only override model is used.
* No role-specific propagation flags are supported.
* Any future need for explicit deny semantics, nested groups, or alternate precedence rules requires a follow-up ADR.

## Consequences

* Section 6 reflects the exact authorization algorithm defined by this ADR.
* Section 8 describes additive union semantics, downward scope interpretation, and flat group behavior explicitly.
* Section 10 includes scenarios that cover direct versus group-derived grants and ancestor-scope matching.
* Implementations should add automated tests for the validation scenarios below before relying on local authorization behavior.

## Validation Scenarios

* A user with a direct workspace grant for `project.view` is allowed to request that permission for a project inside that workspace before policy evaluation.
* A user with no matching grant at the requested scope or any ancestor is denied by default and the denial is audited.
* A user who receives the required permission only through a group-derived grant is allowed if policy also allows the action.
* A user with both direct and group-derived grants receives the union of those permissions with no special precedence rule.
* A tenant-scoped grant is recognized when the request targets a descendant environment.
* An environment-scoped grant does not authorize access to a sibling environment.
* A request with the required permission is still denied when policy requires MFA or approval and the requirement is not satisfied.
* A parent-scope grant can still be blocked by a stricter child-scope policy.
* Nested groups are rejected or treated as unsupported in the first implementation.

## Pros and Cons of the Options

### Resolve access through additive grants only, with policy handling all denials and restrictions

* Good, because authorization behavior stays simple and consistent across scopes.
* Good, because restrictive business and security rules remain in the policy layer.
* Good, because audit reasoning can distinguish missing permission from policy denial.
* Bad, because the model does not support explicit deny exceptions in the authorization layer.

### Support additive grants plus explicit deny semantics

* Good, because deny exceptions can be expressed directly in authorization.
* Bad, because precedence and merge behavior become more complex across direct, group, and ancestor-scope grants.
* Bad, because the boundary between authorization and policy becomes less clear.

### Resolve access by nearest-scope precedence only

* Good, because scope selection appears simpler at first glance.
* Bad, because broader-scope grants stop behaving as inherited access context.
* Bad, because teams would need more duplicate grants to express common access patterns.
