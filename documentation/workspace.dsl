workspace "Product Platform" "Starter C4 workspace for a Product platform control-plane system." {

    model {
        platformOperator = person "Platform Operator" "Configures and operates tenant environments." "Operator"
        productEngineer = person "Product Engineer" "Builds and deploys platform capabilities." "Internal User"

        identityProvider = softwaresystem "Identity Provider" "Provides user authentication and identity claims." "External System"
        observabilityStack = softwaresystem "Observability Stack" "Collects logs, metrics, and traces from the control plane." "External System"

        controlPlaneSystem = softwaresystem "Product Platform Control Plane" "Manages tenants, environments, and platform policies." {
            controlPlanePortal = container "Control Plane Portal" "UI for operators and engineering users." "Web UI"
            controlPlaneApi = container "Control Plane API" "Public and internal API surface for control-plane capabilities." "HTTP API" {
                authComponent = component "Auth Component" "Validates identity, session, and role context." "Service Component"
                tenantComponent = component "Tenant Management Component" "Manages tenant lifecycle and metadata." "Service Component"
                environmentComponent = component "Environment Management Component" "Handles environment provisioning intents and state." "Service Component"
                policyComponent = component "Policy Evaluation Component" "Applies platform policy checks for operations." "Service Component"
            }
            orchestrationService = container "Orchestration Service" "Coordinates asynchronous workflows for control-plane requests." "Worker Service"
            metadataStore = container "Metadata Store" "Persists tenant, environment, and operation metadata." "Relational Database"
            eventBus = container "Event Bus" "Transports domain events and workflow messages." "Message Broker"
        }

        platformOperator -> controlPlanePortal "Uses"
        productEngineer -> controlPlanePortal "Uses"

        controlPlanePortal -> controlPlaneApi "Calls"
        controlPlaneApi -> identityProvider "Validates identities with"
        controlPlaneApi -> metadataStore "Reads/writes metadata"
        controlPlaneApi -> eventBus "Publishes commands/events"
        orchestrationService -> eventBus "Consumes events from"
        orchestrationService -> metadataStore "Stores workflow state"
        controlPlaneApi -> observabilityStack "Emits telemetry to"
        orchestrationService -> observabilityStack "Emits telemetry to"

        controlPlanePortal -> authComponent "Sends identity context to"
        controlPlanePortal -> tenantComponent "Calls tenant operations on"
        controlPlanePortal -> environmentComponent "Calls environment operations on"
        controlPlanePortal -> policyComponent "Requests access evaluation from"
        tenantComponent -> policyComponent "Requests authorization decision from"
        environmentComponent -> policyComponent "Requests authorization decision from"

        authComponent -> identityProvider "Exchanges identity data with"
        tenantComponent -> metadataStore "Reads/writes"
        environmentComponent -> eventBus "Publishes orchestration requests"
        policyComponent -> metadataStore "Reads policy and tenancy context"

        deploymentEnvironment "Development" {
            deploymentNode "Developer Workstation" "" "macOS/Windows/Linux" {
                deploymentNode "Browser" "" "Chrome/Firefox/Safari/Edge" {
                    devPortal = containerInstance controlPlanePortal
                }
            }

            deploymentNode "Dev Cluster" "" "Kubernetes" {
                deploymentNode "App Namespace" "" "Containers" {
                    devApi = containerInstance controlPlaneApi
                    devOrchestrator = containerInstance orchestrationService
                }
                deploymentNode "Data Namespace" "" "Managed Services" {
                    devDatabase = containerInstance metadataStore
                    devBus = containerInstance eventBus
                }
            }
        }

        deploymentEnvironment "Live" {
            deploymentNode "Operator Device" "" "Browser-capable workstation" {
                deploymentNode "Browser" "" "Chrome/Firefox/Safari/Edge" {
                    livePortal = containerInstance controlPlanePortal
                }
            }

            deploymentNode "Production Control Plane" "" "Kubernetes" {
                deploymentNode "API Tier" "" "Containers" {
                    liveApi = containerInstance controlPlaneApi
                }
                deploymentNode "Workflow Tier" "" "Containers" {
                    liveOrchestrator = containerInstance orchestrationService
                }
                deploymentNode "Data Tier" "" "Managed Services" {
                    liveDatabase = containerInstance metadataStore
                    liveBus = containerInstance eventBus
                }
            }
        }
    }

    views {
        systemcontext controlPlaneSystem "SystemContext" {
            include *
            autoLayout
        }

        container controlPlaneSystem "Containers" {
            include *
            autoLayout
        }

        component controlPlaneApi "Components" {
            include *
            autoLayout
        }

        dynamic controlPlaneApi "SignIn" "Placeholder runtime flow for control-plane access and request processing." {
            controlPlanePortal -> authComponent "Submits access token to"
            authComponent -> identityProvider "Validates token with"
            controlPlanePortal -> policyComponent "Checks access policy with"
            controlPlanePortal -> environmentComponent "Requests environment operation from"
            environmentComponent -> eventBus "Publishes orchestration command to"
            autoLayout
        }

        deployment controlPlaneSystem "Development" "DevelopmentDeployment" {
            include *
            autoLayout
        }

        deployment controlPlaneSystem "Live" "LiveDeployment" {
            include *
            autoLayout
        }

        styles {
            element "Person" {
                color #ffffff
                shape Person
            }
            element "Operator" {
                background #0b5cab
            }
            element "Internal User" {
                background #2a7a4b
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
            element "Database" {
                shape Cylinder
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
        }
    }
}
