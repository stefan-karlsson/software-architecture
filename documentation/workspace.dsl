workspace "Product Platform Foundation" "C4 model for the platform foundation architecture." {

    model {
        user = person "User" "Human principal that operates within tenant, workspace, project / service, and environment scopes." "Human Principal"

        automationClient = softwaresystem "Automation Client" "Machine-driven client that acts through service accounts." "External System"
        identityProvider = softwaresystem "Identity Provider" "Provides authentication and identity claims for human and machine principals." "External System"
        observabilityStack = softwaresystem "Observability Stack" "Collects audit and operational telemetry from the platform foundation." "External System"

        foundation = softwaresystem "Product Platform Foundation" "Provides hierarchical scoping, authorization, policy inheritance, auditability, and isolation control for the platform." {
            identityAccess = container "Identity and Access Capability" "Manages users, service accounts, groups, memberships, grants, roles, and permissions." "Capability Module"
            policyManagement = container "Policy Management Capability" "Manages platform, tenant, workspace, project, and environment policies and computes effective policy." "Capability Module"
            scopeManagement = container "Tenant Hierarchy and Scope Management Capability" "Manages tenants, billing accounts, subscriptions, workspaces, projects / services, and environments." "Capability Module"
            auditGovernance = container "Audit and Governance Capability" "Records privileged and regulated activity and preserves audit context across the hierarchy." "Capability Module"
            isolationPlacement = container "Isolation and Placement Capability" "Resolves isolation profiles and the runtime, data, and network boundaries for environments." "Capability Module"
        }

        user -> foundation "Uses"
        automationClient -> foundation "Uses service-account-driven access to"
        foundation -> identityProvider "Delegates authentication and identity claims to"
        foundation -> observabilityStack "Emits audit and operational telemetry to"

        user -> identityAccess "Authenticates and administers scoped access through"
        automationClient -> identityAccess "Authenticates service-account access through"
        identityAccess -> identityProvider "Validates principal identity with"
        identityAccess -> scopeManagement "Resolves memberships and grant scopes with"
        identityAccess -> policyManagement "Submits authorization context to"
        identityAccess -> auditGovernance "Audits access and membership changes through"

        scopeManagement -> policyManagement "Provides hierarchy and scope context to"
        scopeManagement -> auditGovernance "Audits tenant, workspace, project / service, and environment changes through"

        policyManagement -> auditGovernance "Audits policy changes and policy decisions through"
        policyManagement -> observabilityStack "Emits policy telemetry to"

        isolationPlacement -> scopeManagement "Resolves subscription and environment context from"
        isolationPlacement -> policyManagement "Applies effective policy constraints from"
        isolationPlacement -> auditGovernance "Audits binding and boundary changes through"

        auditGovernance -> observabilityStack "Exports audit and operational telemetry to"
    }

    views {
        systemcontext foundation "SystemContext" {
            include *
            autoLayout
        }

        container foundation "Capabilities" {
            include *
            autoLayout
        }

        styles {
            element "Person" {
                color #ffffff
                shape Person
            }
            element "Human Principal" {
                background #0b5cab
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External System" {
                background #666666
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Capability Module" {
                background #85bbf0
                color #000000
            }
        }
    }
}
