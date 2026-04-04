# Select identity federation and service-account credential model

## Status

* Status: accepted

## Choose the trust model for users, service accounts, and platform tokens

* Deciders: Architecture Team
* Date: 2026-04-03

## Context and Problem Statement

The accepted architecture says that the Identity Provider is authoritative for external identity claims and that Identity and Access is authoritative for platform-specific identity records, service accounts, groups, memberships, grants, roles, and permissions.
Without a concrete trust and credential model, the platform still lacks one clear way to turn user and automation identity into claims it can authenticate and authorize consistently.

Without a concrete decision, teams can still make materially different assumptions about:

* whether human federation uses OIDC, SAML, or local platform accounts
* whether service-account automation uses short-lived tokens, static API keys, client secrets, or workload identity
* which token shape the platform expects at its public boundary
* how identity claims are mapped into platform identities before authorization and policy evaluation
* how key rotation, token expiry, and issuer trust are enforced

The platform therefore needs one accepted trust and credential direction that aligns with the accepted ownership and authorization model.

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

## Decision Outcome

Chosen option: "OIDC federation for users plus OAuth 2.0 style short-lived tokens for service accounts", because it aligns cleanly with modern identity-provider capabilities, reduces reliance on long-lived shared secrets, and produces claims that fit the accepted ownership and authorization boundaries.

### Normative Trust Profile

* Human users authenticate through an external OpenID Connect-compatible identity provider.
* The platform accepts signed short-lived bearer tokens that carry issuer, subject, audience, expiry, and stable identity claims for the user or service account.
* Service accounts remain platform-managed identities, but automation authenticates with short-lived OAuth 2.0 compatible tokens rather than static API keys.
* Workload identity or private-key-based client authentication is preferred over shared client secrets where the runtime environment supports it.
* Identity and Access maps external token claims to platform identities and then evaluates memberships, grants, roles, permissions, and policy.

### Public Behavior Locked by This Decision

* The platform must validate issuer trust, signature, audience, expiry, and token freshness before authorization begins.
* Claims used for authorization and audit must be stable enough to correlate a request to one platform identity.
* Group, tenant, or organization claims from the external identity provider may inform mapping, but platform grants remain internal source-of-truth records.
* Long-lived static API keys should not be the primary automation credential model in the first implementation.

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
* This ADR does not choose whether the first implementation requires JWT access tokens specifically or also allows opaque tokens with introspection.
* This ADR does not choose the exact claim names used for subject, display, or tenant-correlation inputs at the platform boundary.
* This ADR does not choose whether service accounts use one uniform machine credential flow or a small approved set depending on execution environment.
* This ADR does not choose the detailed operational behavior for revocation, emergency disablement, or key rotation.

## Consequences

* Section 3 should point to this ADR as the accepted trust and credential direction behind the current logical identity integration.
* Future interface and API work should assume short-lived bearer-token authentication rather than static API-key authentication.
* Any proposal for local platform passwords, static machine keys, or SAML-first federation should justify why the accepted direction is insufficient.

## Validation Scenarios

* A human user authenticates through an external OIDC-compatible identity provider without moving platform grant ownership into that provider.
* Service-account-driven automation authenticates through short-lived OAuth-style bearer tokens without relying on long-lived shared API keys.
* The token and claims model provides enough stable context to correlate authorization and audit activity to one platform identity.
* Issuer trust, audience validation, token expiry, and token freshness are enforced consistently at the platform boundary before authorization starts.

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
