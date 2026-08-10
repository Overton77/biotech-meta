# Canonical Conversations, Session Projections, and Durable Realtime

## Problem Statement

The implementation target currently acknowledges any Socket.IO connection based only on the presence of an authentication payload and provides no canonical Conversation, Conversation Thread, durable message, promotion, authorization, subscription, or reconnect model. Without an application-owned interaction record, SDK sessions can be mistaken for durable conversation state, raw messages can be treated as executable instructions, accepted outputs can be lost between socket connections, and reconnecting clients cannot recover safely or prove what they missed.

## Solution

Create PostgreSQL-authoritative Conversations, forkable ordered Conversation Threads, durable messages and interaction records, explicit promotion of conversation content into typed domain commands or revisions, and OpenAI Agents SDK sessions as disposable model-facing projections. Add authenticated and authorized Socket.IO subscriptions that emit versioned projection-change envelopes, persist accepted messages and final outputs before acknowledgement, expose durable cursors scoped to authorized channels, and recover by querying current projections plus replaying from a validated cursor. Conversation content, session history, socket events, and connected clients remain context and evidence rather than execution authority.

## User Stories

1. As a user, I want to create a Conversation as a durable interaction container, so that related work is preserved independently of one browser or agent session.
2. As a user, I want to create multiple Conversation Threads within a Conversation, so that alternative lines of work do not corrupt one ordered history.
3. As a user, I want to fork a thread from an exact durable turn, so that the new branch has explicit lineage and a stable starting context.
4. As an auditor, I want thread participants, roles, scope bindings, parent thread, and fork point recorded, so that each interaction path is explainable.
5. As a user, I want accepted messages assigned a durable thread order, so that concurrent submissions have one canonical sequence.
6. As an API client, I want message submission to be idempotent, so that retries do not create duplicate turns.
7. As a user, I want text, structured content, tool interactions, tool results, approvals, final agent outputs, and durable stream summaries preserved as typed records, so that the conversation is reviewable.
8. As a user, I want token deltas and fine-grained progress streamed with low latency, so that active work feels responsive.
9. As an auditor, I want ephemeral stream fragments clearly distinguished from durable accepted messages and final outputs, so that missing deltas do not imply data loss.
10. As a workflow operator, I want raw conversation content to affect execution only after promotion into an accepted typed record, so that chat text cannot bypass control-plane validation.
11. As a user, I want a promoted record to cite the exact supporting turns, so that executable meaning remains traceable to the discussion.
12. As an approver, I want approvals and rejections recorded as authoritative domain decisions rather than inferred from conversational language, so that intent is unambiguous.
13. As an agent runtime, I want an SDK session populated from an authorized projection of one thread, so that model context is bounded and purpose-specific.
14. As an agent runtime, I want the projection to record included, summarized, excluded, compacted, and redacted items, so that model input can be audited.
15. As a user, I want session compaction or restart to leave the canonical thread unchanged, so that runtime context management cannot rewrite history.
16. As a workflow operator, I want one thread to support multiple SDK sessions across handoffs, model changes, iterations, and restored sandboxes, so that session lifecycle does not define conversation identity.
17. As a security operator, I want one SDK session prohibited from silently joining unrelated threads, so that context cannot cross authorization or purpose boundaries.
18. As a client, I want a socket connection to authenticate a principal and bind tenant and authorization context, so that payload presence is not mistaken for identity.
19. As a client, I want to subscribe only to channels and subjects I am authorized to read, so that room membership cannot leak data.
20. As a client, I want subscription authorization rechecked when policy or membership changes, so that stale sockets do not retain access.
21. As a client, I want every durable realtime envelope to include type, schema version, subject, correlation, aggregate version or cursor, and occurrence time, so that updates are interpretable and orderable.
22. As a client, I want accepted conversation messages acknowledged only after durable commit, so that an acknowledgement means the message can be queried after reconnect.
23. As a client, I want final agent and tool outputs durable before acknowledgement, so that a transport failure cannot erase the accepted result.
24. As a client, I want to reconnect with a durable cursor, so that I can recover authorized changes since my last confirmed position.
25. As a client, I want an expired, malformed, unauthorized, or gapped cursor to trigger a typed resynchronization response, so that recovery does not silently omit events.
26. As a client, I want to query the current projection before or alongside replay, so that sockets are not the correctness mechanism.
27. As an operator, I want cursor progress isolated by principal, tenant, consumer, channel, and subject scope as policy requires, so that one subscription cannot advance another.
28. As an operator, I want socket acknowledgements distinguished from domain command results, so that transport acceptance is not confused with business acceptance.
29. As a workflow observer, I want run, stage, agent, tool, memory, catalog, workspace, budget, approval, artifact, and evaluation projection hints on authorized channels, so that one realtime contract supports the control plane.
30. As a security auditor, I want denied subscriptions, revoked sessions, replay attempts, cursor gaps, and redactions audited, so that access behavior is reviewable.
31. As a service operator, I want server restarts and horizontal instances to preserve reconnect behavior, so that in-memory room state is not required for correctness.
32. As an implementation agent, I want duplicate messages, stale thread versions, fork races, unauthorized subjects, and replay gaps to produce typed outcomes, so that conflict handling is not improvised.

## Implementation Decisions

- PostgreSQL is authoritative for Conversations, Conversation Threads, participants, messages, interaction records, ordering, promotions, subscription read models, consumer cursors, and authorization-relevant projections.
- A Conversation is a durable container. A Conversation Thread is a forkable ordered sequence with optional bindings to a Workflow Run, stage, cycle, operation, sandbox, coordinator, or agent identity.
- Thread fork creation references an exact parent thread and durable fork position. Later parent messages do not become ancestors of the fork automatically.
- Durable message order is assigned transactionally per thread. Clients may submit expected thread versions; stale conflicting writes are rejected or returned for reevaluation rather than accepted last-write-wins.
- Message submission uses a stable client idempotency identity scoped to the thread and principal. Exact duplicates return the prior accepted result; conflicting reuse is rejected.
- Messages, tool interactions, approvals, final outputs, and durable summaries use versioned typed payloads. Large payloads may be durable references, but their acceptance metadata and ordering remain transactional.
- Accepted messages and final agent or tool outputs are committed before application acknowledgement. Token deltas and fine-grained progress may remain ephemeral and are never needed to reconstruct authoritative state.
- Conversation content becomes executable meaning only through an application service that validates and creates a typed record such as an Intake Brief revision, Run Request, Workflow Lifecycle Command, approval decision, Run Control Revision, Goal Revision, Continuation Proposal decision, or linked-run request.
- Every promotion records supporting conversation item identities, proposer, deciding authority, policy, resulting domain identity, and accepted or rejected outcome. A promotion does not mutate the source turns.
- Prompts, messages, tool text, retrieved context, and stream content cannot grant capability, alter workflow topology, authorize a transition, or override an invariant.
- An SDK session is a model-facing projection of one authorized Conversation Thread and declared purpose. It is not the canonical thread, Workflow Run state, mission state, approval state, or durable event stream.
- Session projection records the source thread version range, selected item identities, compaction and redaction decisions, context policy revision, projection digest, target Agent Profile, and session identity.
- A thread may produce many SDK sessions. A session may be replaced, compacted, or abandoned without changing canonical messages. Cross-thread projection requires an explicit authorized context-selection record and cannot silently merge histories.
- Authentication validates a credential or trusted session through project-owned authentication services. The mere presence of a Socket.IO auth object never establishes identity.
- Socket connection establishes principal, tenant, session, expiry, and correlation context. Subscription is a separate authorized operation; connection alone grants no rooms or subjects.
- Channel authorization is evaluated against principal, tenant, subject, participant membership, Workflow Run access, data classification, and requested event classes. Server-side filters apply before payload serialization.
- Authorization is revalidated on subscription, reconnect, and relevant policy or membership change. Revocation removes subscriptions and prevents replay from prior cursors.
- Realtime envelopes are versioned and transport-neutral. They carry stable event identity where durable, channel, subject, aggregate identity and version or durable cursor, occurrence and recording times, correlation and causation, and an authorization-filtered payload or durable reference.
- Durable replay reads from application event or projection records, not Socket.IO history. Socket.IO carries low-latency hints and ephemeral progress.
- A durable cursor is opaque to clients, integrity-protected, scoped to an authorized stream, and monotonic only within that declared scope. There is no promise of global ordering across unrelated aggregates.
- Reconnect performs authentication, cursor validation, authorization, current-projection query, gap detection, and bounded replay. When replay is unavailable or unsafe, the server returns a resynchronization requirement and a fresh authorized position.
- Consumer progress is advanced only after the application accepts the client's replay acknowledgement policy. Transport acknowledgements do not mutate domain aggregates.
- At-least-once durable delivery is assumed. Clients deduplicate by stable event identity and reconcile aggregate versions. Ephemeral events may be lost.
- The FastAPI process owns gateway and Socket.IO integration, but workers, outbox relays, and projectors remain separate process roles. Horizontal socket deployment may use a supported fan-out adapter, but durable correctness remains in PostgreSQL-backed projections and cursors.
- The API exposes typed commands for conversation and thread creation, thread fork, message submission, promotion proposals, and subscriptions, plus queries for thread history, promotion results, current projections, and replay.
- Row-level security is mandatory defense in depth for tenant-scoped conversation, event, and cursor records. Application authorization remains required.
- Sensitive payloads are filtered or replaced by authorized durable references. Cursor possession never bypasses current authorization.

## Testing Decisions

- The highest practical behavioral seam is an authenticated ASGI client exercising both HTTP command/query APIs and a real Socket.IO connection against the same application service layer and transactional test database. Tests observe durable acknowledgements, queries, subscriptions, disconnects, reconnects, and replay rather than internal room calls.
- Conversation tests cover creation, participant authorization, concurrent ordered messages, exact duplicate submission, conflicting idempotency reuse, stale thread versions, and fork lineage.
- Promotion tests prove raw messages do not create execution state, accepted promotions cite exact turns, rejected promotions remain auditable, and unauthorized actors cannot promote commands or approvals.
- SDK projection tests prove compaction, redaction, and fresh-session creation leave canonical thread records unchanged; one session cannot join an unrelated thread without an explicit authorized context-selection decision.
- Authentication tests reject missing, malformed, expired, revoked, and payload-only pseudo-credentials. Subscription tests reject unauthorized tenants, subjects, channels, and event classes.
- Durability tests force disconnect immediately after acknowledged message or final-output submission and verify the record remains queryable and replayable.
- Reconnect tests cover a valid cursor, duplicate replay, out-of-order delivery, aggregate-version gap, expired retention window, malformed cursor, wrong subject, changed authorization, and full resynchronization.
- At-least-once tests deliver duplicate durable envelopes and verify client-facing event identity and projection version support deduplication without data loss.
- Ephemeral-stream tests prove token deltas may be absent after reconnect while final output and durable summary remain available.
- Horizontal/restart tests create a cursor, restart or switch the serving process, reconnect, and recover from durable state without relying on prior in-memory room membership.
- Security tests verify authorization filtering happens before serialization and that payload references, message bodies, session projections, and cursor metadata cannot leak across tenants or threads.
- Prior art is the existing FastAPI TestClient liveness test and Socket.IO smoke path. These tests replace the bootstrap ping seam with the complete externally observable conversation and reconnect contract.
- Tests avoid asserting SDK session storage internals, Socket.IO room names, SQL table names, or event-relay implementation details.

## Out of Scope

- Dashboard or chat user-interface implementation.
- Treating raw conversation as a Mission Specification, Intake Brief, or Run Request.
- Full workflow lifecycle commands beyond the promotion boundary needed to prove integration.
- Choosing a permanent durable event broker.
- Persisting every token delta.
- Global event ordering across unrelated subjects.
- Replacing Temporal durable execution with conversations or sockets.
- Defining all future event payload schemas.
- Long-term transcript retention durations and legal-hold policy.

## Further Notes

- Dependency order: this spec can be implemented independently of schema catalog materialization. It is a prerequisite for the audited conversation-facing views of memory and capability selection and for any coordinator flow that promotes messages into those actions.
- Memory retrievals and capability-selection results may be referenced or summarized in a Conversation Thread, but their own authoritative decisions belong to their respective subsystems.
- SDK sessions, thread context, Socket.IO payloads, and replayed events are non-authoritative context or projections. Only accepted typed application records exercise authority.
- The implementation target must replace its current unauthenticated socket behavior, initialize application PostgreSQL during FastAPI lifespan, and keep the Temporal worker separate from the gateway.
