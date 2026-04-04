# Select identity federation and service-account credential model

## Status

* Status: proposed

## Choose the trust model for users, service accounts, and platform tokens

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The accepted architecture says that the Identity Provider is authoritative for external identity claims and that Identity and Access is authoritative for platform-specific identity records, service accounts, groups, memberships, grants, roles, and permissions.
What remains open is the concrete trust and credential model that turns user and automation identity into claims the platform can authenticate and authorize consistently.

Without a concrete decision, teams can still make materially different assumptions about:

* whether human federation uses OIDC, SAML, or local platform accounts
* whether service-account automation uses short-lived tokens, static API keys, client secrets, or workload identity
* which token shape the platform expects at its public boundary
* how identity claims are mapped into platform identities before authorization and policy evaluation
* how key rotation, token expiry, and issuer trust are enforced

The platform therefore needs one proposed trust and credential direction that aligns with the accepted ownership and authorization model.

## Decision Drivers

* Strong security posture for user and machine access
* Compatibility with the accepted actor, grant, and policy model
* Avoidance of long-lived shared secrets where possible
* Predictable claims handoff into authorization and audit
* Operationally realistic rotation and revocation behavior
* Support for both interactive users and service-account-driven automation

## Considered Options

* OIDC federation for users plus OAuth 2.0 style short-lived tokens for service accounts
* SAML federation for users plus static API keys or long-lived client secrets for automation
* Local platform-managed credentials for both users and service accounts

## Proposed Decision Direction

Leading option: "OIDC federation for users plus OAuth 2.0 style short-lived tokens for service accounts", because it aligns cleanly with modern identity-provider capabilities, reduces reliance on long-lived shared secrets, and produces claims that fit the accepted ownership and authorization boundaries.

### Proposed Trust Profile

* Human users authenticate through an external OpenID Connect-compatible identity provider.
* The platform accepts signed short-lived bearer tokens that carry issuer, subject, audience, expiry, and stable identity claims for the user or service account.
* Service accounts remain platform-managed identities, but automation authenticates with short-lived OAuth 2.0 compatible tokens rather than static API keys.
* Workload identity or private-key-based client authentication is preferred over shared client secrets where the runtime environment supports it.
* Identity and Access maps external token claims to platform identities and then evaluates memberships, grants, roles, permissions, and policy.

### Public Behavior Expected From This Direction

* The platform must validate issuer trust, signature, audience, expiry, and token freshness before authorization begins.
* Claims used for authorization and audit must be stable enough to correlate a request to one platform identity.
* Group, tenant, or organization claims from the external identity provider may inform mapping, but platform grants remain internal source-of-truth records.
* Long-lived static API keys should not be the primary automation credential model in the first implementation.

### Questions To Resolve Before Acceptance

* Whether the first implementation should require JWT access tokens specifically or allow opaque tokens with introspection
* Which claim names become the primary subject, display, and tenant-correlation inputs at the platform boundary
* Whether service accounts use one uniform machine credential flow or a small approved set depending on execution environment
* How revocation, emergency disablement, and key rotation should surface operationally

### Positive Consequences

* The trust model aligns with the accepted boundary between external identity claims and platform access metadata.
* Service-account automation gets a more defensible credential posture than static shared secrets.
* Authorization and audit can rely on stable token-derived identity context.
* Future platform interfaces can share one clear authentication story.

### Negative Consequences

* Token validation, issuer management, and rotation handling become explicit platform concerns.
* Some external environments may make workload identity harder to adopt immediately.
* Local development and integration testing need realistic identity emulation or test issuers.

### Non-Goals and Deferred Decisions

* This ADR does not define exact claim names, token payload schemas, or JWK rotation mechanics.
* This ADR does not define detailed SCIM or directory synchronization behavior.
* This ADR does not make the identity provider the source of truth for platform grants, roles, or memberships.
* This ADR does not choose a vendor-specific identity product.

## Consequences

* Section 3 should point to this ADR as the open concrete trust and credential decision behind the current logical identity integration.
* Future interface and API work should assume short-lived bearer-token authentication rather than static API-key authentication.
* Any proposal for local platform passwords, static machine keys, or SAML-first federation should justify why the proposed direction is insufficient.

## Validation Questions

* Can human access be federated without moving platform grant ownership into the external identity provider?
* Can automation authenticate without relying on long-lived shared API keys?
* Does the token and claims model provide enough stable context for authorization and audit correlation?
* Can issuer trust, audience validation, and token expiry be enforced consistently at the platform boundary?

## Pros and Cons of the Options

### OIDC federation for users plus OAuth 2.0 style short-lived tokens for service accounts

* Good, because it fits modern identity-provider capabilities and short-lived credential practices.
* Good, because it keeps external identity claims separate from internal authorization records.
* Good, because it supports both interactive and automation access with one coherent trust model.
* Bad, because token validation and rotation mechanics must be implemented carefully.

### SAML federation for users plus static API keys or long-lived client secrets for automation

* Good, because some enterprises already operate SAML-based user federation.
* Bad, because automation security degrades when long-lived shared secrets become normal.
* Bad, because the split model creates more boundary complexity between interactive and machine access.

### Local platform-managed credentials for both users and service accounts

* Good, because the platform would own the full identity flow end to end.
* Bad, because it conflicts with the accepted ownership boundary for external identity claims.
* Bad, because it increases security and lifecycle burden for a platform that already assumes external federation.
