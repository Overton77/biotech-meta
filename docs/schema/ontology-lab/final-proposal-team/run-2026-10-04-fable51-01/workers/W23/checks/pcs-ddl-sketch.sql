-- W23 private context store (PCS) DDL SKETCH. ILLUSTRATIVE, NOT A RUNTIME IMPLEMENTATION, NOT RUN AGAINST A SERVER.
-- Status: parser-only. Parsed with pglast 8.4 (libpg_query, PostgreSQL 18.4 grammar) and pglast 7.x (PostgreSQL 17
-- grammar) to show the version boundary of WITHOUT OVERLAPS (results in 08-completion-report.md).
-- Purpose: make the external private-store contract in private-store-interface.md concrete enough to review.
-- Every shared reference is a uid column (text) plus the recorded-time viewpoint; no foreign key, view, FDW or
-- replication link reaches the shared graph. Every private uid starts with 'hu:private-'.

CREATE SCHEMA pcs;
CREATE EXTENSION IF NOT EXISTS btree_gist;  -- documented as "the expected way" for scalar columns in WITHOUT OVERLAPS / EXCLUDE

-- shared-uid domain: a shared uid is never private
CREATE DOMAIN pcs.shared_uid AS text CHECK (VALUE ~ '^hu:[a-z][a-z0-9-]*:[A-Za-z0-9][A-Za-z0-9._~-]*$' AND VALUE NOT LIKE 'hu:private-%');
CREATE DOMAIN pcs.private_uid AS text CHECK (VALUE ~ '^hu:private-[a-z][a-z0-9-]*:[A-Za-z0-9][A-Za-z0-9._~-]*$');

CREATE TABLE pcs.user_context (
  uid pcs.private_uid PRIMARY KEY CHECK (uid LIKE 'hu:private-user-context:%'),
  created_at timestamptz NOT NULL DEFAULT transaction_timestamp()
);

CREATE TABLE pcs.user_context_version (
  uid pcs.private_uid PRIMARY KEY CHECK (uid LIKE 'hu:private-user-context-version:%'),
  user_context_uid pcs.private_uid NOT NULL REFERENCES pcs.user_context (uid) ON DELETE CASCADE,
  goal_version_uids pcs.private_uid[] NOT NULL DEFAULT '{}',
  measurement_uids pcs.private_uid[] NOT NULL DEFAULT '{}',
  declared_condition_uids pcs.shared_uid[] NOT NULL DEFAULT '{}',
  declared_intake_uids pcs.shared_uid[] NOT NULL DEFAULT '{}',
  preference_keys text[] NOT NULL DEFAULT '{}',
  payload_hash text NOT NULL CHECK (payload_hash LIKE 'sha256:%'),
  recorded_at timestamptz NOT NULL DEFAULT transaction_timestamp()
);

-- bitemporal attachment episodes (catalog temporalProfiles.bitemporal_attachment), EXCLUSIVE per user context (TM-R5).
-- An unknown (null) upper bound is stored as an unbounded range end, so the exclusion below rejects POSSIBLE overlaps,
-- which is stricter than TM-R5 (definite overlaps only); PCS bounds are service-assigned instants, so no imprecise bound arises.
CREATE TABLE pcs.has_context_version (
  relationship_uid pcs.private_uid PRIMARY KEY,
  user_context_uid pcs.private_uid NOT NULL REFERENCES pcs.user_context (uid) ON DELETE CASCADE,
  context_version_uid pcs.private_uid NOT NULL REFERENCES pcs.user_context_version (uid) ON DELETE CASCADE,
  valid_period tstzrange NOT NULL CHECK (NOT isempty(valid_period)),
  valid_from_basis text NOT NULL,
  valid_to_basis text NOT NULL,
  recorded_period tstzrange NOT NULL CHECK (NOT isempty(recorded_period)),
  -- any supported PostgreSQL: two-period exclusion = no overlap in BOTH valid and recorded time
  CONSTRAINT has_context_version_exclusive EXCLUDE USING gist (user_context_uid WITH =, valid_period WITH &&, recorded_period WITH &&)
);

-- PostgreSQL 18 and later only: a temporal key over the currently believed episodes (one period). Kept as a separate
-- current-belief table because WITHOUT OVERLAPS checks one range and the episode table above is bitemporal.
CREATE TABLE pcs.current_context_version (
  user_context_uid pcs.private_uid NOT NULL REFERENCES pcs.user_context (uid) ON DELETE CASCADE,
  valid_period tstzrange NOT NULL,
  context_version_uid pcs.private_uid NOT NULL REFERENCES pcs.user_context_version (uid) ON DELETE CASCADE,
  PRIMARY KEY (user_context_uid, valid_period WITHOUT OVERLAPS)
);

CREATE TABLE pcs.personal_measurement (
  uid pcs.private_uid PRIMARY KEY CHECK (uid LIKE 'hu:private-personal-measurement:%'),
  user_context_uid pcs.private_uid NOT NULL REFERENCES pcs.user_context (uid) ON DELETE CASCADE,
  metric_uid pcs.shared_uid NOT NULL,
  lab_test_uid pcs.shared_uid,
  assay_version_uid pcs.shared_uid,
  algorithm_version_uid pcs.shared_uid,
  device_uid pcs.shared_uid,
  method_uid pcs.shared_uid,
  result_kind text NOT NULL CHECK (result_kind IN ('MEASURED', 'CALCULATED', 'INFERRED')),
  value_number numeric,
  unit_code text,
  result_qualifier text NOT NULL CHECK (result_qualifier IN ('NUMERIC', 'BELOW_DETECTION', 'ABOVE_QUANTIFICATION', 'NOT_MEASURED', 'INVALID_SPECIMEN')),
  effective_at timestamptz,
  reported_at timestamptz,
  reference_interval_version_uids pcs.shared_uid[] NOT NULL DEFAULT '{}',
  provenance_kind text NOT NULL CHECK (provenance_kind IN ('LAB_REPORT_UPLOAD', 'DEVICE_IMPORT', 'MANUAL_ENTRY')),
  reported_reference_range_text text,
  lab_report_uid pcs.private_uid,
  shared_viewpoint_recorded_at timestamptz NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  CHECK ((result_qualifier = 'NUMERIC') = (value_number IS NOT NULL)),
  CHECK (result_kind = 'MEASURED' OR algorithm_version_uid IS NOT NULL)
);

CREATE TABLE pcs.recommendation_snapshot (
  uid pcs.private_uid PRIMARY KEY CHECK (uid LIKE 'hu:private-recommendation-snapshot:%'),
  user_context_uid pcs.private_uid NOT NULL REFERENCES pcs.user_context (uid) ON DELETE CASCADE,
  request_uid pcs.private_uid NOT NULL,
  user_context_version_uid pcs.private_uid NOT NULL REFERENCES pcs.user_context_version (uid) ON DELETE CASCADE,
  decided_at timestamptz NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  evidence_recorded_at timestamptz NOT NULL,
  evidence_valid_at timestamptz,
  schema_digest text NOT NULL CHECK (schema_digest LIKE 'sha256:%'),
  policy_version_uid pcs.shared_uid NOT NULL CHECK (policy_version_uid LIKE 'hu:policy-version:%'),
  algorithm_version text NOT NULL,
  catalog_version text NOT NULL,
  intended_use text NOT NULL,
  decision_outcome text NOT NULL,
  rationale_summary text,
  decision_confidence numeric,
  decision_confidence_method text,
  missing_fact_keys text[] NOT NULL DEFAULT '{}',
  snapshot_hash text NOT NULL CHECK (snapshot_hash LIKE 'sha256:%'),
  CHECK (evidence_recorded_at <= recorded_at),
  CHECK (decision_confidence IS NULL OR decision_confidence_method IS NOT NULL)
);

CREATE TABLE pcs.recommendation_option (
  uid pcs.private_uid PRIMARY KEY CHECK (uid LIKE 'hu:private-recommendation-option:%'),
  snapshot_uid pcs.private_uid NOT NULL REFERENCES pcs.recommendation_snapshot (uid) ON DELETE CASCADE,
  subject_uid pcs.shared_uid NOT NULL,
  subject_type text NOT NULL,
  disposition text NOT NULL CHECK (disposition IN ('SELECTED', 'ALTERNATIVE', 'REJECTED', 'BLOCKED')),
  rank integer,
  rejection_reason text,
  blocking_constraint_uids pcs.shared_uid[] NOT NULL DEFAULT '{}',
  evidence_assertion_uids pcs.shared_uid[] NOT NULL DEFAULT '{}',
  adjudication_uids pcs.shared_uid[] NOT NULL DEFAULT '{}',
  applicability_uids pcs.shared_uid[] NOT NULL DEFAULT '{}',
  state_uids pcs.shared_uid[] NOT NULL DEFAULT '{}',
  offer_observation_uids pcs.shared_uid[] NOT NULL DEFAULT '{}',
  CHECK (disposition <> 'REJECTED' OR rejection_reason IS NOT NULL),
  CHECK (disposition <> 'BLOCKED' OR (rank IS NULL AND cardinality(blocking_constraint_uids) > 0))
);

CREATE TABLE pcs.decision_criterion_value (
  uid pcs.private_uid PRIMARY KEY CHECK (uid LIKE 'hu:private-decision-criterion-value:%'),
  option_uid pcs.private_uid NOT NULL REFERENCES pcs.recommendation_option (uid) ON DELETE CASCADE,
  criterion_uid pcs.shared_uid NOT NULL CHECK (criterion_uid LIKE 'hu:decision-criterion:%'),
  value_number numeric,
  value_string text,
  method_version text NOT NULL
);

CREATE TABLE pcs.user_decision (
  uid pcs.private_uid PRIMARY KEY CHECK (uid LIKE 'hu:private-user-decision:%'),
  snapshot_uid pcs.private_uid NOT NULL REFERENCES pcs.recommendation_snapshot (uid) ON DELETE CASCADE,
  option_uid pcs.private_uid REFERENCES pcs.recommendation_option (uid) ON DELETE CASCADE,
  decision_kind text NOT NULL CHECK (decision_kind IN ('CHOSE', 'DECLINED', 'DEFERRED')),
  decided_at timestamptz NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT transaction_timestamp()
);

CREATE TABLE pcs.erasure_tombstone (
  uid pcs.private_uid PRIMARY KEY CHECK (uid LIKE 'hu:private-erasure-tombstone:%'),
  subject_key_hash text NOT NULL,
  erased_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  scope text[] NOT NULL,
  propagation_status jsonb NOT NULL DEFAULT '{}'::jsonb
);

-- insert-only records (INV-507): the application role may insert and read, never update; deletion only through the
-- erasure function that writes the tombstone in the same transaction.
CREATE ROLE pcs_app NOLOGIN;
GRANT USAGE ON SCHEMA pcs TO pcs_app;
GRANT SELECT, INSERT ON pcs.user_context_version, pcs.recommendation_snapshot, pcs.recommendation_option,
      pcs.decision_criterion_value, pcs.user_decision, pcs.personal_measurement TO pcs_app;
REVOKE UPDATE, DELETE ON pcs.user_context_version, pcs.recommendation_snapshot, pcs.recommendation_option,
      pcs.decision_criterion_value, pcs.user_decision, pcs.personal_measurement FROM pcs_app;

-- owner isolation: row-level security is default-deny when enabled without a policy; FORCE also binds the table owner.
ALTER TABLE pcs.recommendation_snapshot ENABLE ROW LEVEL SECURITY;
ALTER TABLE pcs.recommendation_snapshot FORCE ROW LEVEL SECURITY;
CREATE POLICY snapshot_owner_only ON pcs.recommendation_snapshot
  USING (user_context_uid = current_setting('pcs.user_context_uid', true))
  WITH CHECK (user_context_uid = current_setting('pcs.user_context_uid', true));
ALTER TABLE pcs.personal_measurement ENABLE ROW LEVEL SECURITY;
ALTER TABLE pcs.personal_measurement FORCE ROW LEVEL SECURITY;
CREATE POLICY measurement_owner_only ON pcs.personal_measurement
  USING (user_context_uid = current_setting('pcs.user_context_uid', true))
  WITH CHECK (user_context_uid = current_setting('pcs.user_context_uid', true));
