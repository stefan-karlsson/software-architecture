# Repository Guidance

For `documentation/workspace.dsl`:

- Use `softwareSystem` for an independently owned product or system boundary with its own lifecycle, stakeholders, and meaningful existence outside sibling systems.
- Use `container` for a runtime or deployable unit inside a software system, such as a frontend application, shell, API, background worker, or database.
- Do not model shared packages, libraries, SDKs, or other code artifacts as `softwareSystem` or  `container`; instead document them as cross-cutting concepts, implementation details, or supporting diagrams.
- When multiple frontend applications belong to the same product boundary, model them as containers within a single software system rather than as peer software systems.

## Domain Modeling Heuristics

- Start with the business flow, responsibilities, and outcomes before introducing technical structure.
- When scope is broad or unclear, reconstruct the current-state story end to end before editing `workspace.dsl`.
- Prefer business outcomes and domain language over tool-centric descriptions.
- If something is described as updating a system, spreadsheet, database, or report, probe for the business meaning and model that instead.
- Allow conflicting perspectives or duplicate concepts during discovery; reconcile only after important viewpoints are surfaced.
- Record unclear or disputed points as assumptions or open questions instead of forcing false certainty into the model.
- Look for boundary signals in responsibility changes, ownership handoffs, language changes, or conceptual shifts.
- Treat pivotal handoff events as strong clues for `softwareSystem` or `container` boundaries.
- Model the business what and why first; add the technical how only when it is architecturally meaningful.
- Name elements after capabilities, responsibilities, and outcomes, not internal tools, implementation steps, or legacy system habits.
- Use deeper event-storming-style discovery when entering a new domain, when stakeholders describe flows differently, or when the repo shows knowledge gaps around ownership or process.
- Skip heavy domain reconstruction when the change is small and fits an already well-understood flow.

## Domain-Driven Design rules for agents

### 1. Apply DDD where it matters

* Use DDD primarily for **complex, business-critical domains** where business rules, terminology, and invariants are hard to get right.
* Put the deepest modeling effort into the **core domain**.
* Treat generic or supporting subdomains with lighter-weight solutions when they do not differentiate the business. 

### 2. Model the business, not the database or framework

* Start from **business capabilities, workflows, decisions, policies, and invariants**.
* Do not let tables, endpoints, ORM constraints, or vendor models define the domain model.
* Treat the domain model as the source of truth for business meaning. ([Domain Language][1])

### 3. Define explicit bounded contexts

* Split large domains into **bounded contexts** with explicit boundaries.
* Assume the same word can mean different things in different contexts.
* Make boundaries visible in codebases, modules, APIs, teams, and data ownership.
* Name each bounded context explicitly and use that name consistently. 

### 4. Maintain one ubiquitous language per bounded context

* Use one **shared business language** across code, tests, docs, diagrams, conversations, API names, and event names.
* Prefer business terms over technical terms.
* If the language changes, treat it as a **model change** and refactor code accordingly.
* Reject ambiguous names, overloaded terms, and “temporary” technical naming that leaks into the core model. ([Domain Language][1])

### 5. Keep modelers close to code

* Anyone changing the model should understand the implementation.
* Anyone changing the implementation should understand the model.
* When refactoring code, preserve or improve domain meaning instead of only improving structure. ([Domain Language][1])

### 6. Use collaborative discovery

* Use **EventStorming** or similar collaborative modeling to explore flows, roles, decisions, events, bottlenecks, and boundary candidates.
* Use workshops to discover domain language and expose misunderstandings early.
* Prefer collaborative exploration before committing to service boundaries or aggregate design. ([EventStorming][2])

### 7. Prefer entities only when identity truly matters

* Model something as an **entity** only when it has continuity and identity over time.
* Choose identity deliberately; make it stable.
* Do not create entities just because something has a database row. ([dddcommunity.org][3])

### 8. Prefer value objects by default

* Default to **value objects** when identity is not required.
* Make value objects **immutable**.
* Let value objects carry behavior, calculations, and validation that do not rely on identity.
* Replace primitives with value objects when business meaning matters. ([dddcommunity.org][3])

### 9. Design aggregates around invariants and consistency boundaries

* Use **aggregates** to protect transactional consistency and domain invariants.
* Keep aggregates **small**.
* Load and save aggregates as whole units.
* Do not grow aggregates to mirror full object graphs or database joins. ([martinfowler.com][4])

### 10. Expose only aggregate roots

* External references should point only to the **aggregate root**.
* Child entities should be modified only through aggregate behavior.
* Do not allow external code to bypass the root and mutate internals directly. ([martinfowler.com][4])

### 11. Do not cross aggregate boundaries with transactions

* Keep transactions inside a single aggregate whenever possible.
* When a business process spans multiple aggregates, use **events and eventual consistency** instead of one large transactional model.
* Reference other aggregates by **identity**, not by deep object references. ([martinfowler.com][4])

### 12. Put business logic inside the domain model

* Business rules, state transitions, and invariant checks belong in **entities, value objects, and aggregates**.
* Avoid an **anemic domain model** where entities are only data carriers and all business logic lives in services.
* Prefer behavior-rich domain types over CRUD-style data bags. ([Microsoft Learn][5])

### 13. Use domain services sparingly

* Create a **domain service** only when important domain behavior does not naturally belong to a single entity or value object.
* Keep domain services stateless and expressed in the domain language.
* Do not use domain services as a dumping ground for misplaced entity logic. 

### 14. Keep application services thin

* Use **application services** to orchestrate use cases, transactions, authorization, and calls to domain objects.
* Application services should coordinate; they should not own core business rules.
* Domain decisions should stay in the domain layer. ([Microsoft Learn][5])

### 15. Isolate the domain layer

* Keep the domain layer free from UI, transport, persistence, broker, ORM, and framework concerns.
* Infrastructure should support the model, not shape it.
* Domain objects should not depend directly on infrastructure details. ([Domain Language][1])

### 16. Package by domain concepts, not technical layers

* Group code into **cohesive domain modules** that tell the story of the system.
* Prefer packages like `agreement`, `merchant`, `pricing`, `risk`, `settlement` over `controllers`, `services`, `utils`, or `models`.
* Module names should be part of the ubiquitous language. ([Domain Language][1])

### 17. Use repositories as domain-facing persistence abstractions

* Use repositories as **collection-like abstractions** between the domain and persistence layers.
* Keep update-side consistency controlled by **aggregate roots** and repository boundaries.
* Place repository interfaces near the domain model and implementations in infrastructure.
* Repositories are useful, but they are **not mandatory in every design**. ([martinfowler.com][6])

### 18. Treat domain events as business facts

* A **domain event** is something meaningful that already happened in the domain.
* Use domain events to express side effects explicitly and coordinate across aggregates.
* Distinguish **domain events** from **integration events**; integration events cross process or bounded-context boundaries asynchronously.
* Do not publish low-value technical events like “row inserted” when a business event exists. ([Microsoft Learn][7])

### 19. Protect your model from external systems

* Use an **anti-corruption layer** when integrating with upstream or legacy systems whose models should not leak into your own.
* Translate foreign concepts into your own domain language at the boundary.
* Use gateways, adapters, translators, and facades to keep the model clean. ([Domain Language][1])

### 20. Prefer explicit integration relationships

* Use **shared kernel** only with tight coordination, and keep it very small.
* Use **open host service** and **published language** for stable, documented contracts shared across boundaries.
* Be explicit about upstream/downstream relationships and translation points. ([Domain Language][1])

### 21. Let domain analysis drive service boundaries

* Treat bounded contexts as **service candidates**, not as accidental leftovers from team structure or current code layout.
* Prefer boundaries that are cohesive in business terms and loosely coupled in integration terms.
* Revisit boundaries when language, ownership, or coupling indicates the current split is wrong. ([Microsoft Learn][8])

### 22. Treat DDD as iterative

* DDD is not a one-time modeling exercise.
* Refine the model continuously as the team learns more.
* Use refactoring to deepen the model, not only to clean syntax or structure. ([Domain Language][1])

### 23. Test the domain directly

* Unit test **domain behavior and invariants in memory**.
* Use integration tests for persistence, brokers, and external systems.
* Favor fast tests that exercise domain rules without requiring a database when possible. ([Microsoft Learn][9])

### 24. Prefer these naming conventions

* Name **bounded contexts, entities, value objects, services, commands, and events** with domain language, not technical slang.
* Name **commands** as requested business actions, usually with a clear verb phrase.
* Name **domain events** as completed business facts, usually in past tense.
* Name **value objects** as nouns that capture meaning, such as `Money`, `Address`, `MerchantNumber`, `AgreementTerm`, or `RiskLevel`. ([dddcommunity.org][3])

### 25. Avoid these anti-patterns

* Do not model one giant “enterprise” domain with one universal vocabulary.
* Do not let database tables define aggregates.
* Do not expose child entities outside aggregate roots.
* Do not spread one business rule across controllers, handlers, repositories, and validators.
* Do not reuse external vendor terminology inside the core domain unless the business truly uses that language.
* Do not create large cross-context shared models just to reduce duplication.
* Do not force full DDD ceremony onto trivial CRUD problems. 

## Agent behavior checklist

* Before introducing a new type, ask: **is this an entity, a value object, an aggregate, or just a DTO?** ([Microsoft Learn][5])
* Before introducing a new service, ask: **does this logic belong inside an entity or value object instead?** 
* Before creating a new boundary, ask: **is this a real bounded context with its own language and model?** ([martinfowler.com][10])
* Before integrating with another system, ask: **do we need an anti-corruption layer?** ([Domain Language][1])
* Before adding a transaction, ask: **can this stay inside one aggregate, or should it become event-driven?** ([martinfowler.com][4])
* Before renaming a concept, ask: **does the change need to propagate through code, tests, docs, events, and APIs?** ([Domain Language][1])

[1]: https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf "Microsoft Word - pdf version of final doc - Mar 2015.docx"
[2]: https://www.eventstorming.com/?utm_source=chatgpt.com "EventStorming"
[3]: https://www.dddcommunity.org/resources/ddd_terms/?utm_source=chatgpt.com "Glossary of Domain-Driven Design Terms"
[4]: https://martinfowler.com/bliki/DDD_Aggregate.html "D D D_ Aggregate"
[5]: https://learn.microsoft.com/en-us/azure/architecture/microservices/model/tactical-domain-driven-design "Use Tactical DDD to Design Microservices - Azure Architecture Center | Microsoft Learn"
[6]: https://martinfowler.com/eaaCatalog/repository.html "Repository"
[7]: https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/domain-events-design-implementation?utm_source=chatgpt.com "Domain events: Design and implementation - .NET"
[8]: https://learn.microsoft.com/en-us/azure/architecture/microservices/model/domain-analysis "Use Domain Analysis to Model Microservices - Azure Architecture Center | Microsoft Learn"
[9]: https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design "Designing the infrastructure persistence layer - .NET | Microsoft Learn"
[10]: https://martinfowler.com/bliki/BoundedContext.html?utm_source=chatgpt.com "Bounded Context"
