workspace "Platform Control Plane" "C4 model for the platform control plane architecture." {

    model {
        user = person "User" "Human user that operates within tenant, workspace, workload, and environment scopes." "Human User"

        automationClient = softwaresystem "Automation Client" "Machine-driven client that acts through service accounts." "External System"
        identityProvider = softwaresystem "Identity Provider" "Provides authentication and identity claims for users and service accounts." "External System"
        observabilityStack = softwaresystem "Observability Stack" "Collects audit and operational telemetry from the platform control plane." "External System"

        foundation = softwaresystem "Platform Control Plane" "Provides hierarchical scoping, authorization, inherited rules and guardrails, auditability, and isolation control for the Product Platform." {
            marketingApp = container "Marketing Site" "Public-facing browser experience served at www.example.com." "Browser application" "Browser Application"
            appShell = container "Tenant Portal" "Thin browser portal served at app.example.com. Coordinates tenant navigation, session handoff, and feature composition." "Browser shell" "Browser Shell"
            adminShell = container "Administration Portal" "Thin browser portal served at admin.example.com. Coordinates administration navigation, session handoff, and feature composition." "Browser shell" "Browser Shell"
            authApp = container "Sign-In Portal" "Shared sign-in and sign-out browser experience served at login.example.com." "Browser application" "Browser Application"
            foundationApi = container "Platform Governance API" "Versioned HTTPS JSON REST API serving browser and automation clients for governed platform capabilities." "Versioned HTTPS JSON REST API" "API" {
                identityAccess = component "Identity and Access" "Resolves platform-specific identity records, service accounts, groups, memberships, grants, roles, and permissions."
                policyManagement = component "Policy" "Manages platform, tenant, workspace, workload, and environment policy rules and guardrails, and computes the combined effective policy."
                scopeManagement = component "Scope Hierarchy" "Manages tenants, billing accounts, subscriptions, workspaces, workloads, and environments."
                auditGovernance = component "Audit Evidence" "Records privileged and regulated activity, preserves audit context, and exports operational telemetry."
                isolationPlacement = component "Environment Isolation" "Resolves runtime allocation, data boundaries, and network boundaries for environments under policy constraints."
            }
        }

        user -> marketingApp "Browses public product and acquisition journeys through"
        user -> appShell "Uses tenant browser journeys through"
        user -> adminShell "Uses administrative browser journeys through"
        user -> authApp "Authenticates through"

        appShell -> authApp "Delegates sign-in and session establishment to"
        adminShell -> authApp "Delegates sign-in and session establishment to"
        appShell -> foundationApi "Supports tenant browser journeys through"
        adminShell -> foundationApi "Supports administrative browser journeys through"
        authApp -> identityProvider "Uses identity federation with"

        automationClient -> identityAccess "Authenticates service-account access through"
        appShell -> identityAccess "Starts sign-in, access, and membership journeys through"
        adminShell -> identityAccess "Starts sign-in, access, and membership journeys through"
        appShell -> policyManagement "Reads governing rules and guardrails through"
        adminShell -> policyManagement "Reads and manages governing rules and guardrails through"
        appShell -> scopeManagement "Navigates tenants, workspaces, workloads, and environments through"
        adminShell -> scopeManagement "Navigates tenants, workspaces, workloads, and environments through"
        appShell -> auditGovernance "Reviews audit evidence through"
        adminShell -> auditGovernance "Reviews audit evidence through"
        appShell -> isolationPlacement "Reviews resolved environment boundaries through"
        adminShell -> isolationPlacement "Reviews resolved environment boundaries through"

        foundationApi -> identityProvider "Delegates authentication and identity claims to"
        foundationApi -> observabilityStack "Emits audit and operational telemetry to"
        identityAccess -> identityProvider "Validates actor identity with"
        identityAccess -> scopeManagement "Resolves memberships and grant scopes with"
        identityAccess -> policyManagement "Submits authorization context to"
        identityAccess -> auditGovernance "Audits access and membership changes through"

        scopeManagement -> policyManagement "Provides hierarchy and scope context to"
        scopeManagement -> auditGovernance "Audits tenant, workspace, workload, and environment changes through"

        policyManagement -> auditGovernance "Audits policy changes and policy decisions through"
        policyManagement -> observabilityStack "Emits policy telemetry to"

        isolationPlacement -> scopeManagement "Resolves subscription and environment context from"
        isolationPlacement -> policyManagement "Applies combined effective policy constraints from"
        isolationPlacement -> auditGovernance "Audits binding and boundary changes through"

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
            include appShell
            include adminShell
            include authApp
            include foundationApi
            include identityProvider
            include observabilityStack
            autoLayout
            title "Container View - Platform Control Plane"
            description "Runtime containers inside the Platform Control Plane and their relationships to users and external systems."
        }

        component foundationApi "Capabilities" {
            include automationClient
            include appShell
            include adminShell
            include identityProvider
            include observabilityStack
            include identityAccess
            include policyManagement
            include scopeManagement
            include auditGovernance
            include isolationPlacement
            autoLayout
            title "Component View - Platform Governance API"
            description "Logical backend building blocks inside the Platform Governance API container."
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
