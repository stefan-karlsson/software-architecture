workspace "Platform Control Plane" "C4 model for the platform control plane architecture." {

    model {
        user = person "User" "Human user that operates within tenant, workspace, workload, and environment scopes." "Human User"

        automationClient = softwaresystem "Automation Client" "Machine-driven client that acts through service accounts and short-lived access tokens." "External System"
        identityProvider = softwaresystem "Identity Provider" "Provides OIDC-compatible federation and identity claims for users and service accounts." "External System"
        observabilityStack = softwaresystem "Observability Stack" "Collects audit and operational telemetry from the platform control plane." "External System"

        foundation = softwaresystem "Platform Control Plane" "Provides hierarchical scoping, authorization, inherited rules and guardrails, auditability, and isolation control for the Product Platform." {
            marketingApp = container "Marketing App" "Public-facing browser app served at www.example.com." "Browser application" "Browser Application"
            tenantApp = container "Tenant App" "Thin browser app served at app.example.com. Coordinates tenant navigation, session handoff, and browser-feature-module composition." "Browser application" "Browser Application"
            administrationApp = container "Administration App" "Thin browser app served at admin.example.com. Coordinates administration navigation, session handoff, and browser-feature-module composition." "Browser application" "Browser Application"
            signInApp = container "Sign-In App" "Shared sign-in and sign-out browser app served at login.example.com." "Browser application" "Browser Application"
            platformManagementApi = container "Platform Management API" "Versioned HTTPS JSON REST API serving browser and automation clients for governed platform capabilities." "Versioned HTTPS JSON REST API" "API" {
                identityAccess = component "Identity and Access" "Resolves platform-specific identity records, service accounts, groups, memberships, grants, roles, and permissions."
                policyManagement = component "Policy" "Manages platform, tenant, workspace, workload, and environment policy rules and guardrails, and computes the combined effective policy."
                platformHierarchy = component "Platform Hierarchy" "Manages tenants, billing accounts, subscriptions, workspaces, workloads, and environments."
                auditGovernance = component "Audit Records" "Records privileged and regulated activity, preserves audit context, and exports operational telemetry."
                environmentIsolation = component "Environment Isolation" "Resolves environment placement, data boundaries, and network boundaries for environments under policy constraints."
            }
        }

        user -> marketingApp "Browses public product and acquisition journeys through"
        user -> tenantApp "Uses tenant browser journeys through"
        user -> administrationApp "Uses administrative browser journeys through"
        user -> signInApp "Authenticates through"

        tenantApp -> signInApp "Delegates sign-in and session establishment to"
        administrationApp -> signInApp "Delegates sign-in and session establishment to"
        tenantApp -> platformManagementApi "Supports tenant browser journeys through"
        administrationApp -> platformManagementApi "Supports administrative browser journeys through"
        signInApp -> identityProvider "Uses OIDC-compatible federation with"

        automationClient -> identityAccess "Authenticates service-account access through"
        tenantApp -> identityAccess "Starts sign-in, access, and membership journeys through"
        administrationApp -> identityAccess "Starts sign-in, access, and membership journeys through"
        tenantApp -> policyManagement "Reads governing rules and guardrails through"
        administrationApp -> policyManagement "Reads and manages governing rules and guardrails through"
        tenantApp -> platformHierarchy "Navigates tenants, workspaces, workloads, and environments through"
        administrationApp -> platformHierarchy "Navigates tenants, workspaces, workloads, and environments through"
        tenantApp -> auditGovernance "Reviews audit records through"
        administrationApp -> auditGovernance "Reviews audit records through"
        tenantApp -> environmentIsolation "Reviews resolved environment boundaries through"
        administrationApp -> environmentIsolation "Reviews resolved environment boundaries through"

        platformManagementApi -> identityProvider "Delegates token validation and identity claims to"
        platformManagementApi -> observabilityStack "Emits audit and operational telemetry to"
        identityAccess -> identityProvider "Validates actor identity with"
        identityAccess -> platformHierarchy "Resolves memberships and grant scopes with"
        identityAccess -> policyManagement "Submits authorization context to"
        identityAccess -> auditGovernance "Audits access and membership changes through"

        platformHierarchy -> policyManagement "Provides hierarchy and scope context to"
        platformHierarchy -> auditGovernance "Audits tenant, workspace, workload, and environment changes through"

        policyManagement -> auditGovernance "Audits policy changes and policy decisions through"
        policyManagement -> observabilityStack "Emits policy telemetry to"

        environmentIsolation -> platformHierarchy "Resolves subscription and environment context from"
        environmentIsolation -> policyManagement "Applies combined effective policy constraints from"
        environmentIsolation -> auditGovernance "Audits binding and boundary changes through"

        auditGovernance -> observabilityStack "Exports audit and operational telemetry to"
    }

    views {
        systemcontext foundation "SystemContext" {
            include user
            include automationClient
            include foundation
            include identityProvider
            include observabilityStack
            autoLayout
            title "System Context - Platform Control Plane"
            description "People and external software systems that interact with the Platform Control Plane."
        }

        container foundation "Containers" {
            include user
            include automationClient
            include marketingApp
            include tenantApp
            include administrationApp
            include signInApp
            include platformManagementApi
            include identityProvider
            include observabilityStack
            autoLayout
            title "Container View - Platform Control Plane"
            description "Runtime containers inside the Platform Control Plane and their relationships to users and external systems."
        }

        component platformManagementApi "Capabilities" {
            include automationClient
            include tenantApp
            include administrationApp
            include identityProvider
            include observabilityStack
            include identityAccess
            include policyManagement
            include platformHierarchy
            include auditGovernance
            include environmentIsolation
            autoLayout
            title "Component View - Platform Management API"
            description "Logical backend building blocks inside the Platform Management API container."
        }

        styles {
            element "Person" {
                color #ffffff
                shape Person
            }
            element "Human User" {
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
            element "Browser Application" {
                shape WebBrowser
            }
            element "Browser Shell" {
                shape WebBrowser
            }
            element "API" {
                background #2e7d32
                color #ffffff
            }
        }
    }
}
