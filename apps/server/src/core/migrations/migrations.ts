export const enterpriseHubMigrations = [
  {
    key: '20260401_enterprise_hub_v1_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS enterprise_listing (
        id varchar(64) PRIMARY KEY,
        organization_id varchar(64) NOT NULL UNIQUE,
        primary_board_type varchar(32) NOT NULL,
        secondary_capabilities jsonb NOT NULL DEFAULT '[]'::jsonb,
        name varchar(128) NOT NULL DEFAULT '',
        short_intro text NOT NULL DEFAULT '',
        full_intro text,
        logo_file_asset_id varchar(64),
        cover_file_asset_id varchar(64),
        album_image_file_asset_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
        province_code varchar(32) NOT NULL DEFAULT '',
        province_name varchar(64) NOT NULL DEFAULT '',
        city_code varchar(32) NOT NULL DEFAULT '',
        city_name varchar(64) NOT NULL DEFAULT '',
        address text,
        founded_at date,
        team_size_range varchar(32),
        cooperation_modes jsonb NOT NULL DEFAULT '[]'::jsonb,
        legal_name_snapshot varchar(256),
        unified_social_credit_code_snapshot varchar(64),
        verification_status_snapshot varchar(32),
        enterprise_status varchar(32) NOT NULL DEFAULT 'unpublished',
        display_status varchar(32) NOT NULL DEFAULT 'hidden',
        contact_visible boolean NOT NULL DEFAULT false,
        published_at timestamptz,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE TABLE IF NOT EXISTS enterprise_profile_company (
        enterprise_id varchar(64) PRIMARY KEY,
        exhibition_types jsonb NOT NULL DEFAULT '[]'::jsonb,
        service_items jsonb NOT NULL DEFAULT '[]'::jsonb,
        service_cities jsonb NOT NULL DEFAULT '[]'::jsonb,
        team_size integer,
        max_project_scale varchar(128),
        average_delivery_cycle_days integer,
        known_clients jsonb NOT NULL DEFAULT '[]'::jsonb,
        qualification_desc text,
        project_management_capability text,
        onsite_execution_capability text,
        board_score_company numeric(5,2),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE TABLE IF NOT EXISTS enterprise_profile_factory (
        enterprise_id varchar(64) PRIMARY KEY,
        process_types jsonb NOT NULL DEFAULT '[]'::jsonb,
        core_products jsonb NOT NULL DEFAULT '[]'::jsonb,
        equipment_list jsonb NOT NULL DEFAULT '[]'::jsonb,
        plant_area_sqm integer,
        monthly_capacity_desc text,
        urgent_order_capability varchar(32),
        urgent_cycle_desc text,
        warehouse_capability boolean,
        transport_capability varchar(32),
        max_order_capacity_desc text,
        production_qualification_desc text,
        delivery_radius_desc text,
        board_score_factory numeric(5,2),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE TABLE IF NOT EXISTS enterprise_profile_supplier (
        enterprise_id varchar(64) PRIMARY KEY,
        supply_categories jsonb NOT NULL DEFAULT '[]'::jsonb,
        supply_mode jsonb NOT NULL DEFAULT '[]'::jsonb,
        core_products_or_services jsonb NOT NULL DEFAULT '[]'::jsonb,
        response_sla_desc text,
        stock_status_desc text,
        delivery_range text,
        aftersales_policy text,
        partner_cases_desc text,
        supply_qualification_desc text,
        board_score_supplier numeric(5,2),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE TABLE IF NOT EXISTS enterprise_case (
        id varchar(64) PRIMARY KEY,
        enterprise_id varchar(64) NOT NULL,
        board_type varchar(32) NOT NULL,
        title varchar(128) NOT NULL,
        exhibition_type varchar(128),
        city varchar(128),
        event_time date,
        summary text NOT NULL,
        case_cover_file_asset_id varchar(64) NOT NULL,
        case_media_file_asset_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
        is_featured boolean NOT NULL DEFAULT false,
        sort_order integer,
        case_status varchar(32) NOT NULL DEFAULT 'draft',
        review_note text,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE TABLE IF NOT EXISTS enterprise_certification_snapshot (
        id varchar(64) PRIMARY KEY,
        enterprise_id varchar(64) NOT NULL,
        certification_type varchar(64) NOT NULL,
        certification_name varchar(128) NOT NULL,
        certification_file_asset_id varchar(64) NOT NULL,
        cert_status varchar(32) NOT NULL DEFAULT 'pending',
        reviewer_id varchar(64),
        review_note text,
        verified_at timestamptz
      )`,
      `CREATE TABLE IF NOT EXISTS enterprise_service_area (
        id varchar(64) PRIMARY KEY,
        enterprise_id varchar(64) NOT NULL,
        area_type varchar(32) NOT NULL,
        province_code varchar(32) NOT NULL,
        province_name varchar(64) NOT NULL,
        city_code varchar(32),
        city_name varchar(64)
      )`,
      `CREATE TABLE IF NOT EXISTS enterprise_contact (
        id varchar(64) PRIMARY KEY,
        enterprise_id varchar(64) NOT NULL,
        contact_name varchar(64) NOT NULL,
        mobile varchar(32),
        wechat varchar(64),
        phone varchar(32),
        email varchar(128),
        position varchar(64),
        is_primary boolean NOT NULL DEFAULT false,
        visible_to_public boolean NOT NULL DEFAULT false
      )`,
      `CREATE TABLE IF NOT EXISTS enterprise_application (
        id varchar(64) PRIMARY KEY,
        enterprise_id varchar(64) NOT NULL,
        apply_board_type varchar(32) NOT NULL,
        applicant_name varchar(64) NOT NULL,
        applicant_mobile varchar(32) NOT NULL,
        submitted_material_snapshot jsonb,
        application_status varchar(32) NOT NULL DEFAULT 'draft',
        rejection_reason text,
        submitted_at timestamptz,
        reviewed_at timestamptz,
        reviewer_id varchar(64),
        review_note text,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE TABLE IF NOT EXISTS enterprise_review_summary (
        enterprise_id varchar(64) PRIMARY KEY,
        avg_score numeric(5,2),
        review_count integer,
        keyword_tags jsonb NOT NULL DEFAULT '[]'::jsonb,
        delivery_score numeric(5,2),
        quality_score numeric(5,2),
        communication_score numeric(5,2),
        last_updated_at timestamptz
      )`,
      `CREATE TABLE IF NOT EXISTS enterprise_recommendation_slot (
        id varchar(64) PRIMARY KEY,
        board_type varchar(32) NOT NULL,
        slot_position integer NOT NULL,
        enterprise_id varchar(64) NOT NULL,
        start_at timestamptz NOT NULL,
        end_at timestamptz NOT NULL,
        source_type varchar(32) NOT NULL,
        score_snapshot numeric(5,2),
        slot_status varchar(32) NOT NULL DEFAULT 'pending',
        created_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE TABLE IF NOT EXISTS enterprise_media_asset_ref (
        id varchar(64) PRIMARY KEY,
        enterprise_id varchar(64) NOT NULL,
        owner_type varchar(64) NOT NULL,
        owner_id varchar(64) NOT NULL,
        media_role varchar(64) NOT NULL,
        file_asset_id varchar(64) NOT NULL,
        sort_order integer,
        created_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_enterprise_recommendation_slot_board_position_time
       ON enterprise_recommendation_slot (board_type, slot_position, start_at, end_at)`
    ]
  },
  {
    key: '20260410_enterprise_display_workbench_media_truth',
    statements: [
      `ALTER TABLE enterprise_profile_factory
       ADD COLUMN IF NOT EXISTS showcase_image_file_asset_ids jsonb NOT NULL DEFAULT '[]'::jsonb`,
      `ALTER TABLE enterprise_profile_factory
       ADD COLUMN IF NOT EXISTS factory_name varchar(128)`,
      `ALTER TABLE enterprise_listing
       DROP CONSTRAINT IF EXISTS enterprise_listing_organization_id_key`,
      `DROP INDEX IF EXISTS idx_enterprise_listing_organization_unique`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_enterprise_listing_organization_board_unique
       ON enterprise_listing (organization_id, primary_board_type)`
    ]
  },
  {
    key: '20260416_enterprise_location_capability_v1_truth',
    statements: [
      `ALTER TABLE enterprise_listing
       ADD COLUMN IF NOT EXISTS district_code varchar(32)`,
      `ALTER TABLE enterprise_listing
       ADD COLUMN IF NOT EXISTS district_name varchar(64)`,
      `ALTER TABLE enterprise_listing
       ADD COLUMN IF NOT EXISTS public_display_address text`,
      `ALTER TABLE enterprise_listing
       ADD COLUMN IF NOT EXISTS latitude double precision`,
      `ALTER TABLE enterprise_listing
       ADD COLUMN IF NOT EXISTS longitude double precision`,
      `ALTER TABLE enterprise_listing
       ADD COLUMN IF NOT EXISTS geo_source varchar(64)`,
      `ALTER TABLE enterprise_listing
       ADD COLUMN IF NOT EXISTS geo_status varchar(32)`,
      `ALTER TABLE enterprise_listing
       ADD COLUMN IF NOT EXISTS last_geocoded_at timestamptz`,
      `ALTER TABLE enterprise_listing
       ADD COLUMN IF NOT EXISTS map_provider varchar(32)`
    ]
  }
];

export const projectPublishCorridorMigrations = [
  {
    key: '20260402_project_publish_minimum_corridor_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS project (
        id varchar(64) PRIMARY KEY,
        project_no varchar(64) NOT NULL UNIQUE,
        organization_id varchar(64) NOT NULL DEFAULT '',
        creator_user_id varchar(64),
        creator_actor_id varchar(64),
        title varchar(128) NOT NULL,
        building_type varchar(64) NOT NULL,
        budget_amount numeric(12,2) NOT NULL,
        description text,
        state varchar(32) NOT NULL DEFAULT 'published',
        summary jsonb NOT NULL DEFAULT '{}'::jsonb,
        published_at timestamptz,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE TABLE IF NOT EXISTS upload_session (
        id varchar(64) PRIMARY KEY,
        business_type varchar(32) NOT NULL,
        business_id varchar(64),
        file_kind varchar(32) NOT NULL,
        mime_type varchar(128) NOT NULL,
        size integer NOT NULL,
        checksum varchar(128) NOT NULL,
        object_key varchar(255) NOT NULL UNIQUE,
        direct_upload_url text NOT NULL,
        direct_upload_method varchar(16) NOT NULL DEFAULT 'PUT',
        direct_upload_headers jsonb NOT NULL DEFAULT '{}'::jsonb,
        session_status varchar(32) NOT NULL DEFAULT 'initiated',
        file_asset_id varchar(64),
        actor_id varchar(64),
        user_id varchar(64),
        organization_id varchar(64) NOT NULL DEFAULT '',
        created_at timestamptz NOT NULL DEFAULT now(),
        confirmed_at timestamptz
      )`,
      `CREATE TABLE IF NOT EXISTS file_asset (
        id varchar(64) PRIMARY KEY,
        upload_session_id varchar(64) NOT NULL UNIQUE,
        business_type varchar(32) NOT NULL,
        business_id varchar(64),
        file_kind varchar(32) NOT NULL,
        object_key varchar(255) NOT NULL UNIQUE,
        mime_type varchar(128) NOT NULL,
        size integer NOT NULL,
        checksum varchar(128) NOT NULL,
        actor_id varchar(64),
        user_id varchar(64),
        organization_id varchar(64) NOT NULL DEFAULT '',
        created_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE TABLE IF NOT EXISTS project_publish_audit_log (
        id varchar(64) PRIMARY KEY,
        aggregate_type varchar(32) NOT NULL,
        aggregate_id varchar(64) NOT NULL,
        event_type varchar(64) NOT NULL,
        actor_id varchar(64),
        user_id varchar(64),
        organization_id varchar(64) NOT NULL DEFAULT '',
        request_id varchar(64) NOT NULL DEFAULT '',
        trace_id varchar(64) NOT NULL DEFAULT '',
        payload jsonb NOT NULL DEFAULT '{}'::jsonb,
        created_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_project_publish_audit_log_aggregate
       ON project_publish_audit_log (aggregate_type, aggregate_id, created_at)`,
      `CREATE INDEX IF NOT EXISTS idx_upload_session_business_binding
       ON upload_session (business_type, business_id, file_kind)`,
      `CREATE INDEX IF NOT EXISTS idx_file_asset_business_binding
       ON file_asset (business_type, business_id, file_kind)`
    ]
  },
  {
    key: '20260403_project_publish_address_range_truth',
    statements: [
      `ALTER TABLE project ADD COLUMN IF NOT EXISTS province_name text`,
      `ALTER TABLE project ADD COLUMN IF NOT EXISTS city_name text`,
      `ALTER TABLE project ADD COLUMN IF NOT EXISTS district_name text`,
      `ALTER TABLE project ADD COLUMN IF NOT EXISTS detail_address text`,
      `ALTER TABLE project ADD COLUMN IF NOT EXISTS scope_summary text`,
      `ALTER TABLE project ADD COLUMN IF NOT EXISTS planned_start_at date`,
      `ALTER TABLE project ADD COLUMN IF NOT EXISTS planned_end_at date`
    ]
  },
  {
    key: '20260404_project_publish_round_b_richer_truth',
    statements: [
      `ALTER TABLE project ADD COLUMN IF NOT EXISTS area_sqm numeric(10,2)`,
      `ALTER TABLE project ADD COLUMN IF NOT EXISTS building_type_remark varchar(100)`,
      `ALTER TABLE project ADD COLUMN IF NOT EXISTS schedule_detail varchar(200)`
    ]
  },
  {
    key: '20260404_project_location_standardization_truth',
    statements: [
      `ALTER TABLE project ADD COLUMN IF NOT EXISTS province_code text`,
      `ALTER TABLE project ADD COLUMN IF NOT EXISTS city_code text`,
      `ALTER TABLE project ADD COLUMN IF NOT EXISTS district_code text`
    ]
  }
];

export const membershipEntitlementMigrations = [
  {
    key: '20260405_membership_entitlement_v1_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS organization_paid_memberships (
        id varchar(64) PRIMARY KEY,
        organization_id varchar(64) NOT NULL,
        tier_code varchar(32) NOT NULL,
        effective_at timestamptz NOT NULL,
        expires_at timestamptz,
        source_type varchar(32) NOT NULL,
        source_ref varchar(128),
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_organization_paid_memberships_org_window
       ON organization_paid_memberships (organization_id, effective_at DESC, expires_at)`,
      `CREATE TABLE IF NOT EXISTS organization_membership_quota_snapshots (
        id varchar(64) PRIMARY KEY,
        organization_id varchar(64) NOT NULL,
        quota_type varchar(64) NOT NULL,
        current_value integer,
        refresh_rule varchar(64),
        next_refresh_at timestamptz,
        last_refreshed_at timestamptz,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_organization_membership_quota_org_type
       ON organization_membership_quota_snapshots (organization_id, quota_type)`,
      `CREATE INDEX IF NOT EXISTS idx_organization_membership_quota_org_refresh
       ON organization_membership_quota_snapshots (organization_id, next_refresh_at)`
    ]
  }
];

export const creditDepositTransactionGuaranteeMigrations = [
  {
    key: '20260406_credit_deposit_transaction_guarantee_v1_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS organization_credit_constraint_postures (
        id varchar(64) PRIMARY KEY,
        organization_id varchar(64) NOT NULL,
        credit_constraint_status varchar(32) NOT NULL,
        performance_constraint_status varchar(32) NOT NULL,
        restriction_reason_code varchar(64),
        advisory_reason_code varchar(64),
        execution_availability_status varchar(32) NOT NULL,
        explanation_key varchar(64) NOT NULL,
        handoff_key varchar(64) NOT NULL,
        dependency_key varchar(64),
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_organization_credit_constraint_postures_org
       ON organization_credit_constraint_postures (organization_id)`,
      `CREATE TABLE IF NOT EXISTS organization_deposit_postures (
        id varchar(64) PRIMARY KEY,
        organization_id varchar(64) NOT NULL,
        requirement_status varchar(32) NOT NULL,
        eligibility_status varchar(32) NOT NULL,
        restriction_status varchar(32) NOT NULL,
        deposit_posture_status varchar(32) NOT NULL,
        handoff_key varchar(64) NOT NULL,
        dependency_key varchar(64),
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_organization_deposit_postures_org
       ON organization_deposit_postures (organization_id)`,
      `CREATE TABLE IF NOT EXISTS organization_transaction_guarantee_postures (
        id varchar(64) PRIMARY KEY,
        organization_id varchar(64) NOT NULL,
        eligibility_status varchar(32) NOT NULL,
        restriction_status varchar(32) NOT NULL,
        explanation_key varchar(64) NOT NULL,
        handoff_key varchar(64) NOT NULL,
        dependency_key varchar(64),
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_organization_transaction_guarantee_postures_org
       ON organization_transaction_guarantee_postures (organization_id)`
    ]
  }
];

export const paymentBillingMigrations = [
  {
    key: '20260406_payment_billing_v1_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS organization_payment_statuses (
        id varchar(64) PRIMARY KEY,
        organization_id varchar(64) NOT NULL,
        payment_status_code varchar(32) NOT NULL,
        payment_availability_code varchar(32) NOT NULL,
        payment_handoff_key varchar(64) NOT NULL,
        payment_explanation_key varchar(64) NOT NULL,
        payment_dependency_key varchar(64),
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_organization_payment_statuses_org
       ON organization_payment_statuses (organization_id)`,
      `CREATE TABLE IF NOT EXISTS organization_billing_references (
        id varchar(64) PRIMARY KEY,
        organization_id varchar(64) NOT NULL,
        billing_reference_status_code varchar(32) NOT NULL,
        billing_reference_code varchar(128),
        billing_reference_visibility_code varchar(32) NOT NULL,
        billing_explanation_key varchar(64) NOT NULL,
        billing_handoff_key varchar(64) NOT NULL,
        billing_dependency_key varchar(64),
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_organization_billing_references_org
       ON organization_billing_references (organization_id)`,
      `CREATE TABLE IF NOT EXISTS organization_payment_handoffs (
        id varchar(64) PRIMARY KEY,
        organization_id varchar(64) NOT NULL,
        handoff_status_code varchar(32) NOT NULL,
        handoff_target_family varchar(64) NOT NULL,
        handoff_explanation_key varchar(64) NOT NULL,
        dependency_required boolean NOT NULL DEFAULT false,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_organization_payment_handoffs_org
       ON organization_payment_handoffs (organization_id)`
    ]
  }
];

export const authPublicLoginMigrations = [
  {
    key: '20260406_auth_public_login_carriers',
    statements: [
      `CREATE TABLE IF NOT EXISTS audit_logs (
        id uuid PRIMARY KEY,
        object_type varchar(64) NOT NULL,
        object_id varchar(64) NOT NULL,
        object_no varchar(128) NOT NULL DEFAULT '',
        action varchar(64) NOT NULL,
        actor_id varchar(64),
        actor_role varchar(64) NOT NULL DEFAULT '',
        before_state varchar(64) NOT NULL DEFAULT '',
        after_state varchar(64) NOT NULL DEFAULT '',
        reason text NOT NULL DEFAULT '',
        request_id varchar(64) NOT NULL DEFAULT '',
        trace_id varchar(64) NOT NULL DEFAULT '',
        occurred_at timestamptz NOT NULL DEFAULT now()
      )`,
      `ALTER TABLE audit_logs
       ALTER COLUMN actor_id DROP NOT NULL`,
      `ALTER TABLE audit_logs
       ALTER COLUMN occurred_at SET DEFAULT now()`,
      `CREATE INDEX IF NOT EXISTS idx_audit_logs_object_action_time
       ON audit_logs (object_type, object_id, action, occurred_at)`,
      `CREATE INDEX IF NOT EXISTS idx_audit_logs_object_no_action_time
       ON audit_logs (object_type, object_no, action, occurred_at)`,
      `CREATE TABLE IF NOT EXISTS security_events (
        id uuid PRIMARY KEY,
        user_id varchar(64),
        organization_id varchar(64),
        event_type varchar(64) NOT NULL,
        risk_level varchar(32) NOT NULL,
        detail_json jsonb NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_security_events_type_time
       ON security_events (event_type, created_at)`
    ]
  }
];

export const currentSessionScopeMigrations = [
  {
    key: '20260409_sessions_current_organization_scope_truth',
    statements: [
      `ALTER TABLE sessions
       ADD COLUMN IF NOT EXISTS organization_id varchar(64)`
    ]
  }
];

export const personalMinimalEditMigrations = [
  {
    key: '20260406_personal_minimal_edit_avatar_truth',
    statements: [
      `ALTER TABLE users
       ADD COLUMN IF NOT EXISTS avatar_file_asset_id varchar(64)`,
      `CREATE INDEX IF NOT EXISTS idx_users_avatar_file_asset_id
       ON users (avatar_file_asset_id)`
    ]
  }
];

export const profileSafetyP0Migrations = [
  {
    key: '20260407_profile_safety_p0_truth',
    statements: [
      `ALTER TABLE users
       ADD COLUMN IF NOT EXISTS profile_intro text`,
      `CREATE TABLE IF NOT EXISTS content_safety_rules (
        id varchar(64) PRIMARY KEY,
        rule_key varchar(128) NOT NULL UNIQUE,
        rule_type varchar(32) NOT NULL,
        field_scope varchar(64) NOT NULL,
        match_mode varchar(32) NOT NULL,
        pattern text NOT NULL,
        decision varchar(32) NOT NULL,
        reason_code varchar(64) NOT NULL,
        reason_text text NOT NULL,
        engine_type varchar(16) NOT NULL DEFAULT 'rule',
        enabled boolean NOT NULL DEFAULT true,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_content_safety_rules_scope_enabled
       ON content_safety_rules (field_scope, enabled)`,
      `CREATE TABLE IF NOT EXISTS content_safety_snapshots (
        id varchar(64) PRIMARY KEY,
        subject_type varchar(64) NOT NULL,
        subject_id varchar(64) NOT NULL,
        user_id varchar(64) NOT NULL,
        content_type varchar(64) NOT NULL,
        field_key varchar(32) NOT NULL,
        current_value text,
        proposed_value text,
        file_asset_id varchar(64),
        metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
        created_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_content_safety_snapshots_subject
       ON content_safety_snapshots (subject_type, subject_id, created_at)`,
      `CREATE TABLE IF NOT EXISTS content_safety_audit_logs (
        id varchar(64) PRIMARY KEY,
        subject_type varchar(64) NOT NULL,
        subject_id varchar(64) NOT NULL,
        user_id varchar(64),
        actor_id varchar(64),
        actor_role varchar(64) NOT NULL DEFAULT '',
        action varchar(64) NOT NULL,
        engine_type varchar(16) NOT NULL,
        decision varchar(32) NOT NULL,
        reason_code varchar(64),
        reason text,
        matched_rule_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
        metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
        request_id varchar(64) NOT NULL DEFAULT '',
        trace_id varchar(64) NOT NULL DEFAULT '',
        created_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_content_safety_audit_logs_subject
       ON content_safety_audit_logs (subject_type, subject_id, created_at)`,
      `CREATE INDEX IF NOT EXISTS idx_content_safety_audit_logs_user_action
       ON content_safety_audit_logs (user_id, action, created_at)`,
      `CREATE TABLE IF NOT EXISTS profile_safety_submissions (
        id varchar(64) PRIMARY KEY,
        user_id varchar(64) NOT NULL,
        field_key varchar(32) NOT NULL,
        status varchar(32) NOT NULL,
        current_value text,
        proposed_value text,
        proposed_file_asset_id varchar(64),
        proposed_avatar_url text,
        engine_type varchar(16) NOT NULL,
        rule_decision varchar(32) NOT NULL,
        matched_rule_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
        reject_reason_code varchar(64),
        reject_reason text,
        submitted_by varchar(64) NOT NULL,
        reviewed_by varchar(64),
        reviewed_at timestamptz,
        resubmitted_from_id varchar(64),
        metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_profile_safety_submissions_user_field_status
       ON profile_safety_submissions (user_id, field_key, status, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_profile_safety_submissions_status_created
       ON profile_safety_submissions (status, created_at DESC)`,
      `INSERT INTO content_safety_rules
        (id, rule_key, rule_type, field_scope, match_mode, pattern, decision, reason_code, reason_text, engine_type, enabled)
       VALUES
        ('p0_reserved_official', 'reserved_official', 'reserved_word', 'profile', 'substring', '官方', 'block', 'reserved_word', '资料内容包含平台保留词。', 'rule', true),
        ('p0_reserved_admin', 'reserved_admin', 'reserved_word', 'profile', 'substring', '管理员', 'block', 'reserved_word', '资料内容包含平台保留词。', 'rule', true),
        ('p0_reserved_system', 'reserved_system', 'reserved_word', 'profile', 'substring', '系统', 'block', 'reserved_word', '资料内容包含平台保留词。', 'rule', true),
        ('p0_reserved_customer_service', 'reserved_customer_service', 'reserved_word', 'profile', 'substring', '客服', 'block', 'reserved_word', '资料内容包含平台保留词。', 'rule', true),
        ('p0_contact_mobile', 'contact_mobile', 'contact', 'profile', 'regex', '1[3-9][0-9]{9}', 'block', 'contact_info', '资料内容不得包含联系方式或引流信息。', 'rule', true),
        ('p0_contact_wechat', 'contact_wechat', 'contact', 'profile', 'regex', '(微信|VX|vx|V信|加我|联系我)', 'block', 'contact_info', '资料内容不得包含联系方式或引流信息。', 'rule', true),
        ('p0_sensitive_scam', 'sensitive_scam', 'sensitive_word', 'profile', 'substring', '诈骗', 'block', 'sensitive_word', '资料内容包含明显违规词。', 'rule', true),
        ('p0_sensitive_gambling', 'sensitive_gambling', 'sensitive_word', 'profile', 'substring', '博彩', 'block', 'sensitive_word', '资料内容包含明显违规词。', 'rule', true),
        ('p0_sensitive_adult', 'sensitive_adult', 'sensitive_word', 'profile', 'substring', '裸聊', 'block', 'sensitive_word', '资料内容包含明显违规词。', 'rule', true)
       ON CONFLICT (id) DO NOTHING`
    ]
  }
];

export const forumReportP0Migrations = [
  {
    key: '20260407_forum_report_p0_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS forum_report_ticket (
        id varchar(64) PRIMARY KEY,
        target_type varchar(32) NOT NULL,
        target_id varchar(64) NOT NULL,
        target_author_user_id varchar(64),
        target_organization_id varchar(64),
        reporter_user_id varchar(64) NOT NULL,
        reporter_actor_id varchar(64) NOT NULL,
        reporter_organization_id varchar(64) NOT NULL,
        reason_code varchar(64) NOT NULL,
        reason_detail varchar(200),
        status varchar(32) NOT NULL,
        target_snapshot jsonb NOT NULL DEFAULT '{}'::jsonb,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_forum_report_ticket_target
       ON forum_report_ticket (target_type, target_id, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_forum_report_ticket_status_created
       ON forum_report_ticket (status, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_forum_report_ticket_reporter
       ON forum_report_ticket (reporter_user_id, created_at DESC)`
    ]
  },
  {
    key: '20260407_forum_report_p0_comment_target_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS forum_comment (
        id varchar(64) PRIMARY KEY,
        post_id varchar(64) NOT NULL,
        parent_comment_id varchar(64),
        organization_id varchar(64) NOT NULL,
        author_user_id varchar(64) NOT NULL,
        author_actor_id varchar(64),
        body text NOT NULL,
        state varchar(32) NOT NULL DEFAULT 'published',
        published_at timestamptz NOT NULL DEFAULT now(),
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_forum_comment_post_state_created
       ON forum_comment (post_id, state, created_at ASC)`,
      `CREATE INDEX IF NOT EXISTS idx_forum_comment_parent_state_created
       ON forum_comment (parent_comment_id, state, created_at ASC)`,
      `CREATE INDEX IF NOT EXISTS idx_forum_comment_author_created
       ON forum_comment (author_user_id, created_at DESC)`
    ]
  }
];

export const forumInteractionTruthMigrations = [
  {
    key: '20260424_forum_interaction_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS forum_post_likes (
        id varchar(64) PRIMARY KEY,
        post_id varchar(64) NOT NULL,
        user_id varchar(64) NOT NULL,
        actor_id varchar(64),
        organization_id varchar(64) NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `ALTER TABLE forum_post_likes
       ADD COLUMN IF NOT EXISTS user_id varchar(64)`,
      `ALTER TABLE forum_post_likes
       ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now()`,
      `UPDATE forum_post_likes
       SET user_id = COALESCE(NULLIF(user_id, ''), actor_id, 'legacy-user')
       WHERE user_id IS NULL OR user_id = ''`,
      `ALTER TABLE forum_post_likes
       ALTER COLUMN user_id SET NOT NULL`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_forum_post_likes_user_post
       ON forum_post_likes (user_id, post_id)`,
      `CREATE INDEX IF NOT EXISTS idx_forum_post_likes_post_created
       ON forum_post_likes (post_id, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_forum_post_likes_user_created
       ON forum_post_likes (user_id, created_at DESC)`,
      `CREATE TABLE IF NOT EXISTS forum_post_bookmarks (
        id varchar(64) PRIMARY KEY,
        post_id varchar(64) NOT NULL,
        user_id varchar(64) NOT NULL,
        actor_id varchar(64),
        organization_id varchar(64) NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `ALTER TABLE forum_post_bookmarks
       ADD COLUMN IF NOT EXISTS user_id varchar(64)`,
      `ALTER TABLE forum_post_bookmarks
       ADD COLUMN IF NOT EXISTS actor_id varchar(64)`,
      `ALTER TABLE forum_post_bookmarks
       ADD COLUMN IF NOT EXISTS organization_id varchar(64) NOT NULL DEFAULT ''`,
      `ALTER TABLE forum_post_bookmarks
       ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now()`,
      `UPDATE forum_post_bookmarks
       SET user_id = COALESCE(NULLIF(user_id, ''), actor_id, 'legacy-user')
       WHERE user_id IS NULL OR user_id = ''`,
      `ALTER TABLE forum_post_bookmarks
       ALTER COLUMN user_id SET NOT NULL`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_forum_post_bookmarks_user_post
       ON forum_post_bookmarks (user_id, post_id)`,
      `CREATE INDEX IF NOT EXISTS idx_forum_post_bookmarks_post_created
       ON forum_post_bookmarks (post_id, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_forum_post_bookmarks_user_created
       ON forum_post_bookmarks (user_id, created_at DESC)`,
      `CREATE TABLE IF NOT EXISTS forum_author_follows (
        id varchar(64) PRIMARY KEY,
        follower_user_id varchar(64) NOT NULL,
        follower_actor_id varchar(64),
        follower_organization_id varchar(64) NOT NULL,
        target_author_user_id varchar(64) NOT NULL,
        target_organization_id varchar(64) NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `ALTER TABLE forum_author_follows
       ADD COLUMN IF NOT EXISTS follower_user_id varchar(64)`,
      `ALTER TABLE forum_author_follows
       ADD COLUMN IF NOT EXISTS follower_actor_id varchar(64)`,
      `ALTER TABLE forum_author_follows
       ADD COLUMN IF NOT EXISTS follower_organization_id varchar(64) NOT NULL DEFAULT ''`,
      `ALTER TABLE forum_author_follows
       ADD COLUMN IF NOT EXISTS target_author_user_id varchar(64)`,
      `ALTER TABLE forum_author_follows
       ADD COLUMN IF NOT EXISTS target_organization_id varchar(64) NOT NULL DEFAULT ''`,
      `ALTER TABLE forum_author_follows
       ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now()`,
      `UPDATE forum_author_follows
       SET follower_user_id = COALESCE(NULLIF(follower_user_id, ''), follower_actor_id, 'legacy-user')
       WHERE follower_user_id IS NULL OR follower_user_id = ''`,
      `UPDATE forum_author_follows
       SET target_author_user_id = COALESCE(NULLIF(target_author_user_id, ''), target_organization_id, 'legacy-author')
       WHERE target_author_user_id IS NULL OR target_author_user_id = ''`,
      `ALTER TABLE forum_author_follows
       ALTER COLUMN follower_user_id SET NOT NULL`,
      `ALTER TABLE forum_author_follows
       ALTER COLUMN target_author_user_id SET NOT NULL`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_forum_author_follows_user_author
       ON forum_author_follows (follower_user_id, target_author_user_id)`,
      `CREATE INDEX IF NOT EXISTS idx_forum_author_follows_follower_created
       ON forum_author_follows (follower_user_id, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_forum_author_follows_target_created
       ON forum_author_follows (target_author_user_id, created_at DESC)`
    ]
  },
  {
    key: '20260424_forum_post_likes_legacy_state_default',
    statements: [
      `ALTER TABLE forum_post_likes
       ADD COLUMN IF NOT EXISTS state varchar(32) NOT NULL DEFAULT 'active'`,
      `ALTER TABLE forum_post_likes
       ALTER COLUMN state SET DEFAULT 'active'`,
      `UPDATE forum_post_likes
       SET state = 'active'
       WHERE state IS NULL OR state = ''`
    ]
  }
];


export const blockP0AMigrations = [
  {
    key: '20260407_block_p0a_user_block_relation_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS user_block_relations (
        id varchar(64) PRIMARY KEY,
        blocker_user_id varchar(64) NOT NULL,
        blocked_user_id varchar(64) NOT NULL,
        relation_status varchar(32) NOT NULL DEFAULT 'active',
        ended_at timestamptz,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_user_block_relations_active_pair
       ON user_block_relations (blocker_user_id, blocked_user_id)
       WHERE relation_status = 'active'`,
      `CREATE INDEX IF NOT EXISTS idx_user_block_relations_blocker_active
       ON user_block_relations (blocker_user_id, relation_status)`,
      `CREATE INDEX IF NOT EXISTS idx_user_block_relations_blocked_active
       ON user_block_relations (blocked_user_id, relation_status)`
    ]
  }
];


export const governancePenaltyP1AMigrations = [
  {
    key: '20260408_governance_penalty_p1a_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS governance_penalties (
        id varchar(64) PRIMARY KEY,
        subject_type varchar(32) NOT NULL,
        subject_id varchar(64) NOT NULL,
        penalty_type varchar(32) NOT NULL,
        status varchar(32) NOT NULL,
        reason_code varchar(64) NOT NULL,
        reason_summary text,
        evidence_file_asset_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
        effective_from timestamptz NOT NULL,
        effective_until timestamptz,
        created_by varchar(64) NOT NULL,
        operator_actor_id varchar(64) NOT NULL,
        operator_user_id varchar(64) NOT NULL,
        operator_role varchar(64) NOT NULL DEFAULT '',
        metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_governance_penalties_subject_status_created
       ON governance_penalties (subject_type, subject_id, status, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_governance_penalties_created
       ON governance_penalties (created_at DESC)`
    ]
  }
];

export const governanceAppealP1AMigrations = [
  {
    key: '20260408_governance_appeal_p1a_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS governance_appeal_cases (
        id varchar(64) PRIMARY KEY,
        penalty_id varchar(64) NOT NULL,
        status varchar(32) NOT NULL,
        reason text NOT NULL,
        decision varchar(32),
        decision_note text,
        evidence_file_asset_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
        submitted_by varchar(64) NOT NULL,
        submitted_at timestamptz NOT NULL,
        decided_by varchar(64),
        decided_at timestamptz,
        metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_governance_appeal_cases_penalty_submitted
       ON governance_appeal_cases (penalty_id, submitted_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_governance_appeal_cases_status_submitted
       ON governance_appeal_cases (status, submitted_at DESC)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_governance_appeal_cases_one_active
       ON governance_appeal_cases (penalty_id)
       WHERE status IN ('submitted', 'under_review')`
    ]
  }
];

export const exhibitionReportCaseP0Migrations = [
  {
    key: '20260411_exhibition_report_case_p0_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS exhibition_report_cases (
        id varchar(64) PRIMARY KEY,
        target_type varchar(32) NOT NULL,
        target_id varchar(64) NOT NULL,
        reason_code varchar(64) NOT NULL,
        reason_detail text,
        reporter_user_id varchar(64) NOT NULL,
        reporter_organization_id varchar(64),
        status varchar(32) NOT NULL DEFAULT 'submitted',
        temporary_restriction_state varchar(32) NOT NULL DEFAULT 'not_applied',
        review_task_id varchar(64),
        governance_ticket_ref varchar(64),
        evidence_file_asset_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
        explanation_requested_at timestamptz,
        explanation_due_at timestamptz,
        explanation_received_at timestamptz,
        adjudication_result varchar(32),
        decision_note text,
        decided_at timestamptz,
        closed_at timestamptz,
        metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_exhibition_report_cases_status_created
       ON exhibition_report_cases (status, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_exhibition_report_cases_target_created
       ON exhibition_report_cases (target_type, target_id, created_at DESC)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_exhibition_report_cases_active_reporter_target_reason
       ON exhibition_report_cases (reporter_user_id, target_type, target_id, reason_code)
       WHERE status IN ('submitted', 'under_review', 'explanation_requested', 'escalated')`
    ]
  }
];

export const governanceRescanP2AMigrations = [
  {
    key: '20260408_governance_rescan_p2a_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS governance_rescan_jobs (
        id varchar(64) PRIMARY KEY,
        scope_type varchar(32) NOT NULL DEFAULT 'forum_content',
        status varchar(32) NOT NULL DEFAULT 'queued',
        window_start timestamptz NOT NULL,
        window_end timestamptz NOT NULL,
        candidate_count integer NOT NULL DEFAULT 0,
        flagged_count integer NOT NULL DEFAULT 0,
        reason text NOT NULL,
        rule_set_version varchar(64) NOT NULL DEFAULT '',
        engine_mode varchar(64) NOT NULL DEFAULT '',
        created_by varchar(64) NOT NULL DEFAULT '',
        created_at timestamptz NOT NULL DEFAULT now(),
        completed_at timestamptz,
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_governance_rescan_jobs_scope_type
          CHECK (scope_type = 'forum_content'),
        CONSTRAINT chk_governance_rescan_jobs_status
          CHECK (status IN ('queued', 'running', 'completed', 'failed', 'cancelled'))
      )`,
      `CREATE INDEX IF NOT EXISTS idx_governance_rescan_jobs_scope_status_created
       ON governance_rescan_jobs (scope_type, status, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_governance_rescan_jobs_created
       ON governance_rescan_jobs (created_at DESC)`
    ]
  }
];

export const certificationRevalidationMigrations = [
  {
    key: '20260410_certification_revalidation_audit_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS organization_certification_revalidation_attempt (
        id varchar(64) PRIMARY KEY,
        organization_id varchar(64) NOT NULL,
        certification_id varchar(64),
        triggered_by_user_id varchar(64) NOT NULL,
        triggered_by_actor_id varchar(64) NOT NULL,
        triggered_by_role varchar(64) NOT NULL DEFAULT '',
        source_license_file_id varchar(64) NOT NULL,
        correction_note text,
        before_status varchar(32) NOT NULL,
        after_status varchar(32) NOT NULL,
        command_outcome varchar(32) NOT NULL,
        old_snapshot jsonb NOT NULL DEFAULT '{}'::jsonb,
        requested_snapshot jsonb NOT NULL DEFAULT '{}'::jsonb,
        ocr_snapshot jsonb,
        outcome_reason text,
        request_id varchar(64) NOT NULL DEFAULT '',
        trace_id varchar(64) NOT NULL DEFAULT '',
        created_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_cert_revalidation_attempt_org_created
       ON organization_certification_revalidation_attempt (organization_id, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_cert_revalidation_attempt_cert_created
       ON organization_certification_revalidation_attempt (certification_id, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_cert_revalidation_attempt_outcome_created
       ON organization_certification_revalidation_attempt (command_outcome, created_at DESC)`
    ]
  }
];

export const aiReviewGatewayP1AMigrations = [
  {
    key: '20260408_ai_review_gateway_p1a_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS ai_review_gateway_requests (
        id varchar(64) PRIMARY KEY,
        engine_type varchar(32) NOT NULL,
        provider_key varchar(64) NOT NULL,
        review_object_type varchar(64) NOT NULL,
        object_id varchar(128) NOT NULL,
        policy_profile varchar(64) NOT NULL,
        request_payload_ref varchar(128) NOT NULL,
        trace_id varchar(64) NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_ai_review_gateway_requests_trace_created
       ON ai_review_gateway_requests (trace_id, created_at DESC)`,
      `CREATE TABLE IF NOT EXISTS ai_review_gateway_results (
        id varchar(64) PRIMARY KEY,
        request_id varchar(64) NOT NULL UNIQUE,
        decision varchar(32) NOT NULL,
        risk_score numeric(6,2) NOT NULL DEFAULT 0,
        risk_labels jsonb NOT NULL DEFAULT '[]'::jsonb,
        provider_response_ref varchar(128) NOT NULL,
        status varchar(32) NOT NULL DEFAULT 'queued',
        created_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_ai_review_gateway_results_status
          CHECK (status IN ('queued', 'processing', 'completed', 'failed')),
        CONSTRAINT fk_ai_review_gateway_results_request_id
          FOREIGN KEY (request_id) REFERENCES ai_review_gateway_requests (id) ON DELETE CASCADE
      )`,
      `CREATE INDEX IF NOT EXISTS idx_ai_review_gateway_results_status_created
       ON ai_review_gateway_results (status, created_at DESC)`
    ]
  }
];

export const projectTransactionSkeletonP0Migrations = [
  {
    key: '20260410_bid_submit_p0_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS bids (
        id varchar(64) PRIMARY KEY,
        project_id varchar(64) NOT NULL,
        organization_id varchar(64) NOT NULL,
        actor_id varchar(64),
        user_id varchar(64),
        quote_amount numeric(12,2) NOT NULL,
        proposal_summary text NOT NULL,
        state varchar(32) NOT NULL DEFAULT 'submitted',
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_bids_project_created
       ON bids (project_id, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_bids_organization_created
       ON bids (organization_id, created_at DESC)`
    ]
  }
];

export const bidSubmitQuoteAmountRepairMigrations = [
  {
    key: '20260413_bid_quote_amount_numeric_truth_repair',
    statements: [
      `DO $$
       BEGIN
         IF EXISTS (
           SELECT 1
           FROM information_schema.columns
           WHERE table_schema = 'public'
             AND table_name = 'bids'
             AND column_name = 'quote_amount'
             AND data_type IN ('integer', 'smallint', 'bigint')
         ) THEN
           ALTER TABLE public.bids
             ALTER COLUMN quote_amount TYPE numeric(12,2)
             USING quote_amount::numeric(12,2);
         END IF;
       END $$`
    ]
  }
];

export const bidSeatTruthBackfillMigrations = [
  {
    key: '20260413_bid_seats_truth_runner_backfill',
    statements: [
      `CREATE TABLE IF NOT EXISTS bid_seats (
        seat_id varchar(64) PRIMARY KEY,
        project_id varchar(64) NOT NULL,
        bid_id varchar(64) NOT NULL,
        state varchar(32) NOT NULL DEFAULT 'locked',
        locked_at timestamptz NOT NULL,
        expires_at timestamptz NOT NULL,
        released_at timestamptz,
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_bid_seats_state
          CHECK (state IN ('locked', 'released', 'timed_out'))
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_bid_seats_project_bid_unique
       ON bid_seats (project_id, bid_id)`,
      `CREATE INDEX IF NOT EXISTS idx_bid_seats_project_state_updated
       ON bid_seats (project_id, state, updated_at DESC)`
    ]
  }
];

export const bidDuplicateSubmitRepairMigrations = [
  {
    key: '20260415_bid_duplicate_submission_controlled_repair',
    statements: [
      `DO $$
       BEGIN
         IF EXISTS (
           SELECT 1
           FROM information_schema.columns
           WHERE table_schema = 'public'
             AND table_name = 'bids'
             AND column_name = 'bidder_organization_id'
         ) THEN
           UPDATE public.bids
              SET bidder_organization_id = organization_id
            WHERE (bidder_organization_id IS NULL OR bidder_organization_id = '')
              AND organization_id IS NOT NULL
              AND organization_id <> '';

           CREATE UNIQUE INDEX IF NOT EXISTS idx_bids_project_bidder_unique
             ON public.bids (project_id, bidder_organization_id);
         END IF;
       END $$`
    ]
  }
];

export const bidSubmissionSnapshotAttachmentTruthMigrations = [
  {
    key: '20260424_bid_submission_snapshot_attachment_truth',
    statements: [
      `ALTER TABLE bids
       ADD COLUMN IF NOT EXISTS project_understanding_file_asset_id varchar(64)`,
      `ALTER TABLE bids
       ADD COLUMN IF NOT EXISTS quote_sheet_file_asset_id varchar(64)`,
      `ALTER TABLE bids
       ADD COLUMN IF NOT EXISTS schedule_plan_file_asset_id varchar(64)`
    ]
  }
];

export const bidAwardBridgeCompletionMigrations = [
  {
    key: '20260412_bid_award_bridge_order_contract_seed_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS orders (
        id varchar(64) PRIMARY KEY,
        order_no varchar(64),
        project_id varchar(64) NOT NULL,
        bid_id varchar(64),
        buyer_organization_id varchar(64) NOT NULL,
        supplier_organization_id varchar(64),
        title text,
        total_amount numeric(12,2),
        state varchar(32) NOT NULL DEFAULT 'active',
        activated_at timestamptz,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE TABLE IF NOT EXISTS contracts (
        id varchar(64) PRIMARY KEY,
        order_id varchar(64) NOT NULL,
        state varchar(32) NOT NULL DEFAULT 'pending_confirm',
        summary_text text,
        confirmed_at timestamptz,
        amend_count integer,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `DO $$
       BEGIN
         IF EXISTS (
           SELECT 1
           FROM pg_tables
           WHERE schemaname = 'public'
             AND tablename = 'orders'
             AND tableowner = current_user
         ) THEN
           EXECUTE 'CREATE INDEX IF NOT EXISTS idx_orders_project_updated
                    ON public.orders (project_id, updated_at DESC)';
           EXECUTE 'CREATE INDEX IF NOT EXISTS idx_orders_buyer_state_updated
                    ON public.orders (buyer_organization_id, state, updated_at DESC)';
           EXECUTE 'CREATE INDEX IF NOT EXISTS idx_orders_supplier_state_updated
                    ON public.orders (supplier_organization_id, state, updated_at DESC)';
           EXECUTE 'CREATE UNIQUE INDEX IF NOT EXISTS idx_orders_project_unique
                    ON public.orders (project_id)';
           EXECUTE 'CREATE UNIQUE INDEX IF NOT EXISTS idx_orders_bid_unique
                    ON public.orders (bid_id)
                    WHERE bid_id IS NOT NULL';
         END IF;
       END $$`,
      `DO $$
       BEGIN
         IF EXISTS (
           SELECT 1
           FROM pg_tables
           WHERE schemaname = 'public'
             AND tablename = 'contracts'
             AND tableowner = current_user
         ) THEN
           EXECUTE 'CREATE INDEX IF NOT EXISTS idx_contracts_order_updated
                    ON public.contracts (order_id, updated_at DESC)';
           EXECUTE 'CREATE UNIQUE INDEX IF NOT EXISTS idx_contracts_order_unique
                    ON public.contracts (order_id)';
         END IF;
       END $$`
    ]
  }
];

export const bidToCompletedOrderFulfillmentMigrations = [
  {
    key: '20260425_bid_to_completed_order_fulfillment_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS milestones (
        id varchar(64) PRIMARY KEY,
        order_id varchar(64) NOT NULL,
        sequence_no integer,
        title text,
        amount numeric(12,2),
        state varchar(32) NOT NULL DEFAULT 'pending_submission',
        submitted_at timestamptz,
        submitted_by varchar(64),
        submission_note text,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE TABLE IF NOT EXISTS inspections (
        id varchar(64) PRIMARY KEY,
        milestone_id varchar(64) NOT NULL,
        order_id varchar(64) NOT NULL,
        state varchar(32) NOT NULL DEFAULT 'draft',
        summary_text text,
        submitted_at timestamptz,
        submitted_by varchar(64),
        passed_at timestamptz,
        passed_by varchar(64),
        rectification_count integer NOT NULL DEFAULT 0,
        recheck_count integer NOT NULL DEFAULT 0,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completed_at timestamptz`,
      `CREATE INDEX IF NOT EXISTS idx_milestones_order_sequence
       ON milestones (order_id, sequence_no, updated_at DESC)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_inspections_milestone_unique
       ON inspections (milestone_id)`,
      `CREATE INDEX IF NOT EXISTS idx_inspections_order_state
       ON inspections (order_id, state, updated_at DESC)`
    ]
  }
];

export const projectOrderTruthMigrations = [
  {
    key: '20260520_project_order_truth_state_machine',
    statements: [
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completed_at timestamptz`,
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completion_request_state varchar(32) NOT NULL DEFAULT 'none'`,
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completion_requested_at timestamptz`,
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completion_requested_by varchar(64)`,
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completion_requested_by_organization_id varchar(64)`,
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completion_request_note text`,
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completion_confirmed_at timestamptz`,
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completion_confirmed_by varchar(64)`,
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completion_confirmed_by_organization_id varchar(64)`,
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completion_rejected_at timestamptz`,
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completion_rejected_by varchar(64)`,
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completion_rejected_by_organization_id varchar(64)`,
      `ALTER TABLE orders
       ADD COLUMN IF NOT EXISTS completion_rejection_reason text`,
      `DO $$
       BEGIN
         ALTER TABLE public.orders
           ADD CONSTRAINT chk_orders_state
           CHECK (state IN ('active', 'completed', 'cancelled')) NOT VALID;
       EXCEPTION
         WHEN duplicate_object THEN NULL;
       END $$`,
      `DO $$
       BEGIN
         ALTER TABLE public.orders
           ADD CONSTRAINT chk_orders_required_business_anchor
           CHECK (
             length(btrim(project_id)) > 0
             AND length(btrim(buyer_organization_id)) > 0
             AND supplier_organization_id IS NOT NULL
             AND length(btrim(supplier_organization_id)) > 0
           ) NOT VALID;
       EXCEPTION
         WHEN duplicate_object THEN NULL;
       END $$`,
      `DO $$
       BEGIN
         ALTER TABLE public.orders
           ADD CONSTRAINT chk_orders_completion_request_state
           CHECK (completion_request_state IN ('none', 'requested', 'rejected', 'dispute_reserved', 'confirmed')) NOT VALID;
       EXCEPTION
         WHEN duplicate_object THEN NULL;
       END $$`,
      `CREATE INDEX IF NOT EXISTS idx_orders_seller_state_updated
       ON public.orders (supplier_organization_id, state, updated_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_orders_completion_request_state_updated
       ON public.orders (completion_request_state, updated_at DESC)`
    ]
  }
];

export const authWhitelistTestSessionMigrations = [
  {
    key: '20260410_auth_whitelist_test_session_truth',
    statements: [
      `ALTER TABLE sessions
       ADD COLUMN IF NOT EXISTS auth_mode varchar(32) NOT NULL DEFAULT 'otp_login'`,
      `ALTER TABLE sessions
       ADD COLUMN IF NOT EXISTS issue_reason text`
    ]
  }
];

export const authLoginLegalConsentMigrations = [
  {
    key: '20260413_auth_login_legal_consent_truth',
    statements: [
      `ALTER TABLE sessions
       ADD COLUMN IF NOT EXISTS agreement_version varchar(64)`,
      `ALTER TABLE sessions
       ADD COLUMN IF NOT EXISTS privacy_version varchar(64)`,
      `ALTER TABLE sessions
       ADD COLUMN IF NOT EXISTS agreed_at timestamptz`
    ]
  }
];

export const authPasswordCredentialMigrations = [
  {
    key: '20260413_auth_password_credentials_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS password_credentials (
        user_id varchar(64) PRIMARY KEY,
        password_hash text NOT NULL,
        password_algo varchar(64) NOT NULL,
        password_set_at timestamptz NOT NULL,
        password_updated_at timestamptz NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`
    ]
  }
];

export const projectAttachmentCorridorP1Migrations = [
  {
    key: '20260413_project_attachment_owner_private_corridor_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS project_attachments (
        id varchar(64) PRIMARY KEY,
        project_id varchar(64) NOT NULL,
        file_asset_id varchar(64) NOT NULL,
        file_name text NOT NULL,
        attachment_kind varchar(32) NOT NULL,
        mime_type varchar(128) NOT NULL,
        visibility varchar(32) NOT NULL,
        sort_order integer NOT NULL DEFAULT 0,
        created_by varchar(64) NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_project_attachments_visibility
          CHECK (visibility = 'owner_private'),
        CONSTRAINT chk_project_attachments_attachment_kind
          CHECK (attachment_kind IN ('effect_image', 'construction_doc', 'material_sample', 'equipment_material_list', 'service_list', 'other_material'))
      )`,
      `ALTER TABLE public.project_attachments
       ADD COLUMN IF NOT EXISTS file_name text NOT NULL DEFAULT ''`,
      `ALTER TABLE public.project_attachments
       ADD COLUMN IF NOT EXISTS attachment_kind varchar(32) NOT NULL DEFAULT 'other_material'`,
      `ALTER TABLE public.project_attachments
       ADD COLUMN IF NOT EXISTS mime_type varchar(128) NOT NULL DEFAULT 'application/octet-stream'`,
      `ALTER TABLE public.project_attachments
       ADD COLUMN IF NOT EXISTS visibility varchar(32) NOT NULL DEFAULT 'owner_private'`,
      `ALTER TABLE public.project_attachments
       ADD COLUMN IF NOT EXISTS sort_order integer NOT NULL DEFAULT 0`,
      `ALTER TABLE public.project_attachments
       ADD COLUMN IF NOT EXISTS created_by varchar(64) NOT NULL DEFAULT ''`,
      `DO $$
       BEGIN
         IF EXISTS (
           SELECT 1
           FROM information_schema.columns
           WHERE table_schema = 'public'
             AND table_name = 'project_attachments'
             AND column_name = 'bound_by'
         ) THEN
           UPDATE public.project_attachments
              SET created_by = COALESCE(NULLIF(created_by, ''), bound_by, '')
            WHERE created_by = '';
         END IF;

         IF NOT EXISTS (
           SELECT 1
           FROM pg_constraint
           WHERE conname = 'chk_project_attachments_visibility'
             AND conrelid = 'public.project_attachments'::regclass
         ) THEN
           ALTER TABLE public.project_attachments
             ADD CONSTRAINT chk_project_attachments_visibility
             CHECK (visibility = 'owner_private');
         END IF;

         IF NOT EXISTS (
           SELECT 1
           FROM pg_constraint
           WHERE conname = 'chk_project_attachments_attachment_kind'
             AND conrelid = 'public.project_attachments'::regclass
         ) THEN
           ALTER TABLE public.project_attachments
             ADD CONSTRAINT chk_project_attachments_attachment_kind
             CHECK (attachment_kind IN ('effect_image', 'construction_doc', 'material_sample', 'equipment_material_list', 'service_list', 'other_material'));
         END IF;
       END $$`,
      `CREATE INDEX IF NOT EXISTS idx_project_attachments_project_sort_created
       ON public.project_attachments (project_id, sort_order ASC, created_at ASC)`,
      `CREATE INDEX IF NOT EXISTS idx_project_attachments_file_asset
       ON public.project_attachments (file_asset_id)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_project_attachments_project_file_asset_unique
       ON public.project_attachments (project_id, file_asset_id)`
    ]
  },
  {
    key: '20260427_quote_basis_material_package_v1_attachment_kind_constraint',
    statements: [
      `ALTER TABLE public.project_attachments
       DROP CONSTRAINT IF EXISTS chk_project_attachments_attachment_kind`,
      `ALTER TABLE public.project_attachments
       ADD CONSTRAINT chk_project_attachments_attachment_kind
       CHECK (attachment_kind IN ('effect_image', 'construction_doc', 'material_sample', 'equipment_material_list', 'service_list', 'other_material'))`
    ]
  }
];

export const projectPublicResourceDownloadZoneMigrations = [
  {
    key: '20260414_project_public_resource_download_zone_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS project_public_resources (
        resource_id varchar(64) PRIMARY KEY,
        resource_category varchar(32) NOT NULL,
        title varchar(128) NOT NULL,
        summary text,
        file_asset_id varchar(64) NOT NULL,
        file_name text NOT NULL,
        mime_type varchar(128) NOT NULL,
        visibility varchar(32) NOT NULL,
        sort_order integer NOT NULL DEFAULT 0,
        published_at timestamptz NOT NULL,
        published_by varchar(64) NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_project_public_resources_category
          CHECK (resource_category IN ('contract_template', 'process_guide', 'other_resource')),
        CONSTRAINT chk_project_public_resources_visibility
          CHECK (visibility = 'app_shared'),
        CONSTRAINT chk_project_public_resources_mime
          CHECK (
            mime_type IN (
              'image/png',
              'image/jpeg',
              'image/webp',
              'application/pdf',
              'application/msword',
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
            )
          )
      )`,
      `CREATE INDEX IF NOT EXISTS idx_project_public_resources_catalog_order
       ON public.project_public_resources (visibility, sort_order ASC, published_at DESC, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_project_public_resources_file_asset
       ON public.project_public_resources (file_asset_id)`
    ]
  }
];

export const certificationLicenseFieldCollectionMigrations = [
  {
    key: '20260410_certification_license_field_collection_truth',
    statements: [
      `ALTER TABLE organization_certifications
       ADD COLUMN IF NOT EXISTS legal_person text`,
      `ALTER TABLE organization_certifications
       ADD COLUMN IF NOT EXISTS business_type text`,
      `ALTER TABLE organization_certifications
       ADD COLUMN IF NOT EXISTS registered_capital text`,
      `ALTER TABLE organization_certifications
       ADD COLUMN IF NOT EXISTS business_term text`,
      `ALTER TABLE organization_certifications
       ADD COLUMN IF NOT EXISTS business_scope text`
    ]
  }
];

export const enterpriseDisplayTruthRepairMigrations = [
  {
    key: '20260410_enterprise_display_org_and_cert_truth_repair',
    statements: [
      `ALTER TABLE organization_certifications
       ADD COLUMN IF NOT EXISTS address text`,
      `ALTER TABLE organization_certifications
       ADD COLUMN IF NOT EXISTS established_at date`,
      `WITH candidate_rows AS (
         SELECT
           o.id AS organization_id,
           COALESCE(
             NULLIF(sa.province_code, ''),
             NULLIF(el.province_code, '')
           ) AS province_code,
           COALESCE(
             NULLIF(sa.city_code, ''),
             NULLIF(el.city_code, '')
           ) AS city_code
         FROM organizations o
         LEFT JOIN enterprise_listing el
           ON el.organization_id = o.id
         LEFT JOIN enterprise_service_area sa
           ON sa.enterprise_id = el.id
          AND sa.area_type = 'registered_location'
         WHERE o.province_code = '000000'
            OR o.city_code = '000000'
       ),
       valid_candidates AS (
         SELECT
           organization_id,
           province_code,
           city_code
         FROM candidate_rows
         WHERE province_code IS NOT NULL
           AND city_code IS NOT NULL
           AND province_code <> '000000'
           AND city_code <> '000000'
       ),
       repair_source AS (
         SELECT
           organization_id,
           MIN(province_code) AS province_code,
           MIN(city_code) AS city_code
         FROM valid_candidates
         GROUP BY organization_id
         HAVING COUNT(DISTINCT province_code || '|' || city_code) = 1
       )
       UPDATE organizations o
          SET province_code = repair_source.province_code,
              city_code = repair_source.city_code
         FROM repair_source
        WHERE o.id = repair_source.organization_id
          AND (o.province_code = '000000' OR o.city_code = '000000')`
    ]
  },
  {
    key: '20260417_enterprise_display_album_truth_backfill',
    statements: [
      `ALTER TABLE enterprise_listing
       ADD COLUMN IF NOT EXISTS album_image_file_asset_ids jsonb NOT NULL DEFAULT '[]'::jsonb`
    ]
  }
];

export const personalCertificationDualGateMigrations = [
  {
    key: '20260414_personal_certification_dual_gate_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS personal_certifications (
         id uuid PRIMARY KEY,
         organization_id uuid NOT NULL UNIQUE,
         user_id varchar(64) NOT NULL,
         certification_status varchar(32) NOT NULL,
         real_name varchar(128),
         id_number_masked varchar(32),
         id_card_front_file_id varchar(64),
         provider_request_id varchar(128),
         submitted_at timestamptz,
         reviewed_at timestamptz,
         reject_reason text,
         locked_at timestamptz,
         created_at timestamptz NOT NULL DEFAULT now(),
         updated_at timestamptz NOT NULL DEFAULT now()
       )`,
      `CREATE INDEX IF NOT EXISTS idx_personal_certifications_user
       ON public.personal_certifications (user_id)`,
      `CREATE INDEX IF NOT EXISTS idx_personal_certifications_status
       ON public.personal_certifications (certification_status)`
    ]
  }
];


export const tradingImRoundAMigrations = [
  {
    key: '20260416_trading_im_round_a_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS project_clarifications (
        id varchar(64) PRIMARY KEY,
        project_id varchar(64) NOT NULL,
        author_user_id varchar(64),
        author_actor_id varchar(64),
        author_organization_id varchar(64) NOT NULL DEFAULT '',
        author_role varchar(32) NOT NULL,
        body text NOT NULL,
        attachment_file_asset_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
        lifecycle_state varchar(32) NOT NULL DEFAULT 'active',
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_project_clarifications_project_created
       ON project_clarifications (project_id, created_at)`,
      `CREATE TABLE IF NOT EXISTS bid_private_threads (
        id varchar(64) PRIMARY KEY,
        project_id varchar(64) NOT NULL,
        bid_id varchar(64) NOT NULL,
        project_owner_organization_id varchar(64) NOT NULL,
        bidder_organization_id varchar(64) NOT NULL,
        lifecycle_state varchar(32) NOT NULL DEFAULT 'open',
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_bid_private_threads_project_bid_unique
       ON bid_private_threads (project_id, bid_id)`,
      `CREATE TABLE IF NOT EXISTS bid_thread_messages (
        id varchar(64) PRIMARY KEY,
        thread_id varchar(64) NOT NULL,
        project_id varchar(64) NOT NULL,
        bid_id varchar(64) NOT NULL,
        sender_user_id varchar(64),
        sender_actor_id varchar(64),
        sender_organization_id varchar(64) NOT NULL,
        sender_role varchar(32) NOT NULL,
        body text NOT NULL,
        attachment_file_asset_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
        message_state varchar(32) NOT NULL DEFAULT 'active',
        created_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_bid_thread_messages_thread_created
       ON bid_thread_messages (thread_id, created_at)`,
      `CREATE TABLE IF NOT EXISTS bid_thread_confirmation_cards (
        id varchar(64) PRIMARY KEY,
        thread_id varchar(64) NOT NULL,
        project_id varchar(64) NOT NULL,
        bid_id varchar(64) NOT NULL,
        confirmation_type varchar(32) NOT NULL,
        source_message_id varchar(64) NOT NULL,
        summary text NOT NULL,
        creator_user_id varchar(64),
        creator_actor_id varchar(64),
        creator_organization_id varchar(64) NOT NULL,
        creator_role varchar(32) NOT NULL,
        card_state varchar(32) NOT NULL DEFAULT 'active',
        created_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_bid_thread_confirmation_cards_thread_created
       ON bid_thread_confirmation_cards (thread_id, created_at)`
    ]
  }
];

export const projectNameAccessRequestMigrations = [
  {
    key: '20260424_project_name_access_request_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS project_name_access_requests (
        id varchar(64) PRIMARY KEY,
        project_id varchar(64) NOT NULL,
        requester_organization_id varchar(64) NOT NULL,
        requested_by_user_id varchar(64) NOT NULL,
        requested_by_actor_id varchar(64) NOT NULL DEFAULT '',
        state varchar(32) NOT NULL DEFAULT 'pending',
        reviewed_by_user_id varchar(64),
        reviewed_by_actor_id varchar(64),
        reviewed_at timestamptz,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_project_name_access_requests_state
          CHECK (state IN ('pending', 'approved', 'rejected'))
      )`,
      `CREATE INDEX IF NOT EXISTS idx_project_name_access_requests_project_requester_created
       ON project_name_access_requests (project_id, requester_organization_id, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_project_name_access_requests_requester_updated
       ON project_name_access_requests (requester_organization_id, updated_at DESC)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_project_name_access_requests_one_active_pending
       ON project_name_access_requests (project_id, requester_organization_id)
       WHERE state = 'pending'`
    ]
  }
];

export const bidParticipationRequestMigrations = [
  {
    key: '20260429_bid_participation_request_phase1_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS bid_participation_requests (
        id varchar(64) PRIMARY KEY,
        project_id varchar(64) NOT NULL,
        requester_organization_id varchar(64) NOT NULL,
        requested_by_user_id varchar(64) NOT NULL,
        requested_by_actor_id varchar(64) NOT NULL DEFAULT '',
        state varchar(32) NOT NULL DEFAULT 'pending',
        reviewed_by_user_id varchar(64),
        reviewed_by_actor_id varchar(64),
        reviewed_at timestamptz,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_bid_participation_requests_state
          CHECK (state IN ('pending', 'approved', 'rejected'))
      )`,
      `CREATE INDEX IF NOT EXISTS idx_bid_participation_requests_project_requester_created
       ON bid_participation_requests (project_id, requester_organization_id, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_bid_participation_requests_requester_updated
       ON bid_participation_requests (requester_organization_id, updated_at DESC)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_bid_participation_requests_one_active_pending
       ON bid_participation_requests (project_id, requester_organization_id)
       WHERE state = 'pending'`
    ]
  }
];

export const projectCommunicationAlbumMigrations = [
  {
    key: '20260428_project_communication_and_album_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS project_communication_threads (
        id varchar(64) PRIMARY KEY,
        project_id varchar(64) NOT NULL,
        owner_organization_id varchar(64) NOT NULL,
        counterpart_organization_id varchar(64) NOT NULL,
        thread_state varchar(32) NOT NULL DEFAULT 'open',
        last_message_id varchar(64),
        last_message_at timestamptz,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_project_communication_threads_state
          CHECK (thread_state IN ('open', 'closed'))
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_project_communication_threads_unique_pair
       ON project_communication_threads (project_id, owner_organization_id, counterpart_organization_id)`,
      `CREATE INDEX IF NOT EXISTS idx_project_communication_threads_counterpart_updated
       ON project_communication_threads (counterpart_organization_id, updated_at DESC)`,
      `CREATE TABLE IF NOT EXISTS project_communication_messages (
        id varchar(64) PRIMARY KEY,
        thread_id varchar(64) NOT NULL,
        project_id varchar(64) NOT NULL,
        sender_user_id varchar(64) NOT NULL,
        sender_actor_id varchar(64),
        sender_organization_id varchar(64) NOT NULL,
        message_kind varchar(32) NOT NULL DEFAULT 'text',
        body text NOT NULL,
        payload jsonb NOT NULL DEFAULT '{}'::jsonb,
        client_message_id varchar(96),
        message_state varchar(32) NOT NULL DEFAULT 'active',
        created_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_project_communication_messages_kind
          CHECK (message_kind IN ('text', 'image', 'file', 'confirmation_card')),
        CONSTRAINT chk_project_communication_messages_state
          CHECK (message_state IN ('active', 'removed'))
      )`,
      `CREATE INDEX IF NOT EXISTS idx_project_communication_messages_thread_created
       ON project_communication_messages (thread_id, created_at ASC, id ASC)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_project_communication_messages_client_dedupe
       ON project_communication_messages (thread_id, sender_organization_id, client_message_id)
       WHERE client_message_id IS NOT NULL`,
      `CREATE TABLE IF NOT EXISTS project_communication_read_cursors (
        thread_id varchar(64) NOT NULL,
        organization_id varchar(64) NOT NULL,
        project_id varchar(64) NOT NULL,
        last_read_message_id varchar(64),
        last_read_at timestamptz NOT NULL,
        updated_at timestamptz NOT NULL DEFAULT now(),
        PRIMARY KEY (thread_id, organization_id)
      )`,
      `CREATE INDEX IF NOT EXISTS idx_project_communication_read_cursors_project
       ON project_communication_read_cursors (project_id, organization_id)`,
      `CREATE TABLE IF NOT EXISTS project_album_photos (
        id varchar(64) PRIMARY KEY,
        project_id varchar(64) NOT NULL,
        file_asset_id varchar(64) NOT NULL,
        category varchar(32) NOT NULL,
        caption text,
        mime_type varchar(128) NOT NULL,
        sort_order integer NOT NULL DEFAULT 0,
        photo_state varchar(32) NOT NULL DEFAULT 'active',
        uploaded_by_user_id varchar(64) NOT NULL,
        uploaded_by_actor_id varchar(64),
        uploaded_by_organization_id varchar(64) NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now(),
        removed_at timestamptz,
        CONSTRAINT chk_project_album_photos_category
          CHECK (category IN ('contract', 'progress', 'final', 'defect')),
        CONSTRAINT chk_project_album_photos_state
          CHECK (photo_state IN ('active', 'removed'))
      )`,
      `CREATE INDEX IF NOT EXISTS idx_project_album_photos_project_category_order
       ON project_album_photos (project_id, category, sort_order ASC, created_at ASC)`,
      `CREATE INDEX IF NOT EXISTS idx_project_album_photos_file_asset
       ON project_album_photos (file_asset_id)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_project_album_photos_active_file_asset
       ON project_album_photos (project_id, file_asset_id)
       WHERE photo_state = 'active'`
    ]
  }
];

export const projectConversationWorkbenchV1Migrations = [
  {
    key: '20260501_project_conversation_workbench_v1_messages',
    statements: [
      `ALTER TABLE project_communication_messages
       ADD COLUMN IF NOT EXISTS payload jsonb NOT NULL DEFAULT '{}'::jsonb`,
      `DO $$
       BEGIN
         ALTER TABLE project_communication_messages DROP CONSTRAINT IF EXISTS chk_project_communication_messages_kind;
         ALTER TABLE project_communication_messages
           ADD CONSTRAINT chk_project_communication_messages_kind
           CHECK (message_kind IN ('text', 'image', 'file', 'confirmation_card'));
       END $$`
    ]
  }
];

export const projectCommunicationNotificationPreviewV1Migrations = [
  {
    key: '20260501_project_communication_notification_preview_v1_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS app_notifications (
        id varchar(64) PRIMARY KEY,
        user_id varchar(64) NOT NULL DEFAULT '',
        organization_id varchar(64) NOT NULL DEFAULT '',
        type varchar(64) NOT NULL,
        source varchar(64) NOT NULL,
        title varchar(160) NOT NULL,
        body text,
        project_id varchar(64),
        thread_id varchar(64),
        route_target jsonb NOT NULL DEFAULT '{}'::jsonb,
        read_at timestamptz,
        notification_state varchar(32) NOT NULL DEFAULT 'active',
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_app_notifications_user_created
       ON app_notifications (user_id, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_app_notifications_org_created
       ON app_notifications (organization_id, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_app_notifications_project_thread
       ON app_notifications (project_id, thread_id)`,
      `CREATE TABLE IF NOT EXISTS device_push_tokens (
        id varchar(64) PRIMARY KEY,
        user_id varchar(64) NOT NULL,
        organization_id varchar(64) NOT NULL DEFAULT '',
        platform varchar(32) NOT NULL,
        provider varchar(32) NOT NULL,
        device_token text NOT NULL,
        app_installation_id varchar(128) NOT NULL,
        app_version varchar(64),
        device_label varchar(128),
        token_state varchar(32) NOT NULL DEFAULT 'active',
        last_registered_at timestamptz NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_device_push_tokens_installation_provider
       ON device_push_tokens (app_installation_id, provider)`,
      `CREATE INDEX IF NOT EXISTS idx_device_push_tokens_user
       ON device_push_tokens (user_id)`,
      `CREATE INDEX IF NOT EXISTS idx_device_push_tokens_org
       ON device_push_tokens (organization_id)`,
      `CREATE TABLE IF NOT EXISTS push_delivery_attempts (
        id varchar(64) PRIMARY KEY,
        notification_id varchar(64) NOT NULL,
        device_token_id varchar(64),
        provider varchar(32) NOT NULL,
        attempt_status varchar(32) NOT NULL,
        error_code varchar(96),
        error_message text,
        attempted_at timestamptz NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_push_delivery_attempts_notification
       ON push_delivery_attempts (notification_id)`,
      `CREATE INDEX IF NOT EXISTS idx_push_delivery_attempts_token
       ON push_delivery_attempts (device_token_id)`
    ]
  }
];

export const projectCounterpartyRatingMigrations = [
  {
    key: '20260428_project_counterparty_rating_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS project_counterparty_ratings (
        id varchar(64) PRIMARY KEY,
        order_id varchar(64) NOT NULL,
        project_id varchar(64) NOT NULL,
        rater_organization_id varchar(64) NOT NULL,
        ratee_organization_id varchar(64) NOT NULL,
        rater_user_id varchar(64) NOT NULL,
        rater_actor_id varchar(64),
        score_value integer NOT NULL,
        score_label varchar(32) NOT NULL,
        comment_text text,
        rating_state varchar(32) NOT NULL DEFAULT 'submitted',
        submitted_at timestamptz NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_project_counterparty_ratings_score
          CHECK (score_value BETWEEN 1 AND 5),
        CONSTRAINT chk_project_counterparty_ratings_score_label
          CHECK (score_label IN ('very_satisfied', 'satisfied', 'passable', 'negative')),
        CONSTRAINT chk_project_counterparty_ratings_state
          CHECK (rating_state IN ('submitted'))
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_project_counterparty_ratings_unique_direction
       ON project_counterparty_ratings (order_id, rater_organization_id, ratee_organization_id)`,
      `CREATE INDEX IF NOT EXISTS idx_project_counterparty_ratings_project
       ON project_counterparty_ratings (project_id, submitted_at DESC)`
    ]
  },
  {
    key: '20260602_credit_shadow_source_type_truth',
    statements: [
      `DO $$
       BEGIN
         IF to_regclass('public.organization_shadow_credit_recompute_triggers') IS NOT NULL THEN
           ALTER TABLE organization_shadow_credit_recompute_triggers
             ADD COLUMN IF NOT EXISTS source_type varchar(64) NOT NULL DEFAULT 'order_rating';
         END IF;
       END $$`,
      `DO $$
       BEGIN
         IF to_regclass('public.organization_shadow_credit_ledgers') IS NOT NULL THEN
           ALTER TABLE organization_shadow_credit_ledgers
             ADD COLUMN IF NOT EXISTS source_type varchar(64) NOT NULL DEFAULT 'order_rating';
         END IF;
       END $$`,
      `DO $$
       BEGIN
         IF to_regclass('public.organization_shadow_credit_recompute_triggers') IS NOT NULL THEN
           CREATE INDEX IF NOT EXISTS idx_org_shadow_credit_triggers_source
             ON organization_shadow_credit_recompute_triggers (source_type, source_rating_id);
         END IF;
       END $$`,
      `DO $$
       BEGIN
         IF to_regclass('public.organization_shadow_credit_ledgers') IS NOT NULL THEN
           CREATE INDEX IF NOT EXISTS idx_org_shadow_credit_ledgers_source
             ON organization_shadow_credit_ledgers (source_type, source_rating_id);
         END IF;
       END $$`
    ]
  }
];

export const p0PayMigrations = [
  {
    key: '20260504_p0_pay_payment_execution_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS platform_service_fee_authorizations (
        id varchar(64) PRIMARY KEY,
        task_id varchar(64) NOT NULL,
        bid_id varchar(64) NOT NULL,
        factory_organization_id varchar(64) NOT NULL,
        publisher_organization_id varchar(64) NOT NULL,
        quoted_amount numeric(12,2) NOT NULL,
        fee_rate numeric(8,6) NOT NULL,
        estimated_fee_amount numeric(12,2) NOT NULL,
        final_confirmed_amount numeric(12,2),
        final_fee_amount numeric(12,2),
        payment_channel varchar(32),
        payment_order_id varchar(64),
        authorization_order_id varchar(96),
        status varchar(32) NOT NULL,
        rule_version varchar(64) NOT NULL,
        rule_snapshot_hash varchar(128) NOT NULL,
        agreement_text_snapshot text NOT NULL DEFAULT '',
        agreed_at timestamptz NOT NULL,
        authorized_at timestamptz,
        released_at timestamptz,
        refunded_at timestamptz,
        breach_hold_reason text NOT NULL DEFAULT '',
        breach_held_at timestamptz,
        charged_at timestamptz,
        created_by_user_id varchar(64) NOT NULL DEFAULT '',
        created_by_actor_id varchar(64) NOT NULL DEFAULT '',
        request_id varchar(64) NOT NULL DEFAULT '',
        trace_id varchar(64) NOT NULL DEFAULT '',
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_platform_service_fee_auth_status
          CHECK (status IN (
            'pending_authorization',
            'authorized',
            'authorization_released',
            'pending_contract_confirm',
            'charged',
            'refund_pending',
            'refunded',
            'breach_hold',
            'cancelled',
            'failed',
            'expired'
          )),
        CONSTRAINT chk_platform_service_fee_auth_channel
          CHECK (payment_channel IS NULL OR payment_channel IN ('alipay', 'wechat', 'other'))
      )`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS refunded_at timestamptz`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS breach_hold_reason text NOT NULL DEFAULT ''`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS breach_held_at timestamptz`,
      `CREATE INDEX IF NOT EXISTS idx_platform_service_fee_auth_task_bid
       ON platform_service_fee_authorizations (task_id, bid_id)`,
      `CREATE INDEX IF NOT EXISTS idx_platform_service_fee_auth_payment_order
       ON platform_service_fee_authorizations (payment_order_id)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_platform_service_fee_auth_one_active_bid
       ON platform_service_fee_authorizations (bid_id)
       WHERE status IN ('pending_authorization', 'authorized', 'pending_contract_confirm')`,
      `CREATE TABLE IF NOT EXISTS inquiry_quote_deposits (
        id varchar(64) PRIMARY KEY,
        task_id varchar(64) NOT NULL,
        publisher_organization_id varchar(64) NOT NULL,
        amount numeric(12,2) NOT NULL DEFAULT 200,
        currency varchar(8) NOT NULL DEFAULT 'CNY',
        payment_channel varchar(32),
        payment_order_id varchar(64),
        status varchar(32) NOT NULL,
        rule_version varchar(64) NOT NULL DEFAULT '',
        rule_snapshot_hash varchar(128) NOT NULL DEFAULT '',
        paid_at timestamptz,
        refund_requested_at timestamptz,
        refunded_at timestamptz,
        deducted_at timestamptz,
        deduction_reason text NOT NULL DEFAULT '',
        request_id varchar(64) NOT NULL DEFAULT '',
        trace_id varchar(64) NOT NULL DEFAULT '',
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_inquiry_quote_deposits_status
          CHECK (status IN (
            'pending_payment',
            'paid',
            'refund_pending',
            'refunded',
            'deducted',
            'dispute_hold',
            'cancelled',
            'failed',
            'expired'
          )),
        CONSTRAINT chk_inquiry_quote_deposits_channel
          CHECK (payment_channel IS NULL OR payment_channel IN ('alipay', 'wechat', 'other'))
      )`,
      `CREATE INDEX IF NOT EXISTS idx_inquiry_quote_deposits_task
       ON inquiry_quote_deposits (task_id)`,
      `CREATE INDEX IF NOT EXISTS idx_inquiry_quote_deposits_payment_order
       ON inquiry_quote_deposits (payment_order_id)`,
      `CREATE TABLE IF NOT EXISTS payment_orders (
        id varchar(64) PRIMARY KEY,
        business_type varchar(64) NOT NULL,
        business_id varchar(64) NOT NULL,
        task_id varchar(64) NOT NULL DEFAULT '',
        bid_id varchar(64) NOT NULL DEFAULT '',
        payer_organization_id varchar(64) NOT NULL,
        payee_organization_id varchar(64) NOT NULL DEFAULT '',
        amount numeric(12,2) NOT NULL,
        currency varchar(8) NOT NULL DEFAULT 'CNY',
        payment_channel varchar(32) NOT NULL,
        order_role varchar(32) NOT NULL,
        status varchar(32) NOT NULL,
        merchant_order_no varchar(96) NOT NULL,
        channel_order_id varchar(128),
        idempotency_key_hash varchar(128) NOT NULL,
        request_id varchar(64) NOT NULL DEFAULT '',
        trace_id varchar(64) NOT NULL DEFAULT '',
        expires_at timestamptz,
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_payment_orders_business_type
          CHECK (business_type IN (
            'platform_service_fee_authorization',
            'platform_service_fee_charge',
            'inquiry_deposit'
          )),
        CONSTRAINT chk_payment_orders_channel
          CHECK (payment_channel IN ('alipay', 'wechat', 'other')),
        CONSTRAINT chk_payment_orders_role
          CHECK (order_role IN ('payment', 'authorization', 'refund', 'release')),
        CONSTRAINT chk_payment_orders_status
          CHECK (status IN (
            'created',
            'pending_user_confirm',
            'succeeded',
            'failed',
            'cancelled',
            'closed',
            'release_pending',
            'released',
            'refund_pending',
            'refunded',
            'expired'
          ))
      )`,
      `CREATE INDEX IF NOT EXISTS idx_payment_orders_business
       ON payment_orders (business_type, business_id)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_orders_idempotency_scope
       ON payment_orders (business_type, business_id, idempotency_key_hash)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_orders_merchant_order_no
       ON payment_orders (merchant_order_no)`,
      `CREATE INDEX IF NOT EXISTS idx_payment_orders_channel_order
       ON payment_orders (payment_channel, channel_order_id)`,
      `CREATE TABLE IF NOT EXISTS payment_transactions (
        id varchar(64) PRIMARY KEY,
        payment_order_id varchar(64) NOT NULL,
        transaction_type varchar(32) NOT NULL,
        payment_channel varchar(32) NOT NULL,
        channel_transaction_id varchar(128),
        amount numeric(12,2) NOT NULL,
        requested_amount numeric(12,2),
        confirmed_amount numeric(12,2),
        status varchar(32) NOT NULL,
        channel_action_type varchar(32) NOT NULL DEFAULT 'unavailable',
        channel_reference varchar(128) NOT NULL DEFAULT '',
        raw_status varchar(128) NOT NULL DEFAULT '',
        initiated_at timestamptz,
        confirmed_at timestamptz,
        failed_at timestamptz,
        failure_reason_code varchar(96) NOT NULL DEFAULT '',
        occurred_at timestamptz,
        created_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_payment_transactions_type
          CHECK (transaction_type IN ('authorization', 'payment', 'refund', 'release', 'callback')),
        CONSTRAINT chk_payment_transactions_channel
          CHECK (payment_channel IN ('alipay', 'wechat', 'other')),
        CONSTRAINT chk_payment_transactions_status
          CHECK (status IN ('pending', 'succeeded', 'failed', 'cancelled')),
        CONSTRAINT chk_payment_transactions_action_type
          CHECK (channel_action_type IN ('sdk_payload', 'web_redirect', 'qr_code', 'unavailable', 'server_capture'))
      )`,
      `CREATE INDEX IF NOT EXISTS idx_payment_transactions_order_created
       ON payment_transactions (payment_order_id, created_at)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_transactions_channel_transaction
       ON payment_transactions (payment_channel, channel_transaction_id)
       WHERE channel_transaction_id IS NOT NULL`,
      `CREATE TABLE IF NOT EXISTS payment_callback_events (
        id varchar(64) PRIMARY KEY,
        payment_channel varchar(32) NOT NULL,
        merchant_order_no varchar(96) NOT NULL,
        channel_event_id varchar(128) NOT NULL,
        provider_event_id varchar(128) NOT NULL DEFAULT '',
        event_type varchar(64) NOT NULL,
        event_status varchar(64) NOT NULL DEFAULT '',
        payload_snapshot jsonb NOT NULL DEFAULT '{}'::jsonb,
        callback_payload_hash varchar(128) NOT NULL DEFAULT '',
        verification_status varchar(32) NOT NULL DEFAULT 'received',
        apply_status varchar(32) NOT NULL DEFAULT 'not_applied',
        rejected_reason_code varchar(96) NOT NULL DEFAULT '',
        request_id varchar(64) NOT NULL DEFAULT '',
        trace_id varchar(64) NOT NULL DEFAULT '',
        received_at timestamptz NOT NULL,
        verified_at timestamptz,
        applied_at timestamptz,
        processed_at timestamptz,
        CONSTRAINT chk_payment_callback_events_channel
          CHECK (payment_channel IN ('alipay', 'wechat', 'other')),
        CONSTRAINT chk_payment_callback_events_verification
          CHECK (verification_status IN ('received', 'verified', 'rejected', 'duplicate')),
        CONSTRAINT chk_payment_callback_events_apply
          CHECK (apply_status IN ('not_applied', 'applied', 'duplicate', 'ignored_out_of_order', 'apply_failed'))
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_callback_events_channel_event
       ON payment_callback_events (payment_channel, channel_event_id)`,
      `CREATE INDEX IF NOT EXISTS idx_payment_callback_events_order_received
       ON payment_callback_events (merchant_order_no, received_at)`,
      `CREATE TABLE IF NOT EXISTS contract_confirmations (
        id varchar(64) PRIMARY KEY,
        task_id varchar(64) NOT NULL,
        selected_bid_id varchar(64),
        selected_quotation_id varchar(64),
        publisher_organization_id varchar(64) NOT NULL,
        factory_organization_id varchar(64) NOT NULL,
        final_confirmed_amount numeric(12,2) NOT NULL,
        currency varchar(8) NOT NULL DEFAULT 'CNY',
        publisher_confirmed_at timestamptz,
        factory_confirmed_at timestamptz,
        contract_status varchar(32) NOT NULL,
        contract_file_asset_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
        platform_service_fee_charge_id varchar(64),
        request_id varchar(64) NOT NULL DEFAULT '',
        trace_id varchar(64) NOT NULL DEFAULT '',
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_contract_confirmations_status
          CHECK (contract_status IN ('pending_counterparty', 'confirmed', 'cancelled'))
      )`,
      `CREATE INDEX IF NOT EXISTS idx_contract_confirmations_task_bid
       ON contract_confirmations (task_id, selected_bid_id)`,
      `CREATE INDEX IF NOT EXISTS idx_contract_confirmations_status
       ON contract_confirmations (contract_status)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_contract_confirmations_one_active_bid
       ON contract_confirmations (task_id, selected_bid_id)
       WHERE selected_bid_id IS NOT NULL AND contract_status IN ('pending_counterparty', 'confirmed')`,
      `CREATE TABLE IF NOT EXISTS platform_service_fee_charges (
        id varchar(64) PRIMARY KEY,
        task_id varchar(64) NOT NULL,
        contract_confirmation_id varchar(64) NOT NULL,
        authorization_id varchar(64) NOT NULL,
        factory_organization_id varchar(64) NOT NULL,
        final_confirmed_amount numeric(12,2) NOT NULL,
        fee_rate numeric(8,6) NOT NULL,
        final_fee_amount numeric(12,2) NOT NULL,
        payment_order_id varchar(64),
        charge_status varchar(32) NOT NULL,
        charged_at timestamptz,
        refunded_at timestamptz,
        request_id varchar(64) NOT NULL DEFAULT '',
        trace_id varchar(64) NOT NULL DEFAULT '',
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_platform_service_fee_charges_status
          CHECK (charge_status IN (
            'pending_charge',
            'charged',
            'charge_failed',
            'refund_pending',
            'refunded',
            'cancelled'
          ))
      )`,
      `CREATE INDEX IF NOT EXISTS idx_platform_service_fee_charges_contract
       ON platform_service_fee_charges (contract_confirmation_id)`,
      `CREATE INDEX IF NOT EXISTS idx_platform_service_fee_charges_payment_order
       ON platform_service_fee_charges (payment_order_id)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_platform_service_fee_charges_one_active_contract
       ON platform_service_fee_charges (contract_confirmation_id)
       WHERE charge_status IN ('pending_charge', 'charged', 'refund_pending')`,
      `CREATE TABLE IF NOT EXISTS payment_idempotency_records (
        id varchar(64) PRIMARY KEY,
        operation_key varchar(96) NOT NULL,
        scope_key varchar(256) NOT NULL,
        idempotency_key_hash varchar(128) NOT NULL,
        request_hash varchar(128) NOT NULL,
        resource_type varchar(64) NOT NULL,
        resource_id varchar(64) NOT NULL,
        status varchar(32) NOT NULL,
        request_id varchar(64) NOT NULL DEFAULT '',
        trace_id varchar(64) NOT NULL DEFAULT '',
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_payment_idempotency_records_status
          CHECK (status IN ('succeeded', 'failed'))
      )`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_idempotency_records_scope_key
       ON payment_idempotency_records (operation_key, scope_key, idempotency_key_hash)`
    ]
  },
  {
    key: '20260505_p0_pay_membership_fee_snapshot_truth',
    statements: [
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS fee_rate_label varchar(64) NOT NULL DEFAULT '默认费率 3.0%'`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS fee_rate_source varchar(32) NOT NULL DEFAULT 'legacy_fixed_default'`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS membership_tier_snapshot varchar(32) NOT NULL DEFAULT 'none'`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS fee_rate_rule_version varchar(64) NOT NULL DEFAULT 'exhibition_trade_task_payment_mainline_p0_pay_v1_3'`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS fee_rate_snapshot_hash varchar(128) NOT NULL DEFAULT ''`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS fee_calculated_at timestamptz`,
      `UPDATE platform_service_fee_authorizations
       SET fee_rate_snapshot_hash = rule_snapshot_hash
       WHERE fee_rate_snapshot_hash = ''`,
      `UPDATE platform_service_fee_authorizations
       SET fee_calculated_at = COALESCE(agreed_at, created_at)
       WHERE fee_calculated_at IS NULL`,
      `ALTER TABLE platform_service_fee_charges
       ADD COLUMN IF NOT EXISTS fee_rate_label varchar(64) NOT NULL DEFAULT '默认费率 3.0%'`,
      `ALTER TABLE platform_service_fee_charges
       ADD COLUMN IF NOT EXISTS fee_rate_source varchar(32) NOT NULL DEFAULT 'legacy_fixed_default'`,
      `ALTER TABLE platform_service_fee_charges
       ADD COLUMN IF NOT EXISTS membership_tier_snapshot varchar(32) NOT NULL DEFAULT 'none'`,
      `ALTER TABLE platform_service_fee_charges
       ADD COLUMN IF NOT EXISTS fee_rate_rule_version varchar(64) NOT NULL DEFAULT 'exhibition_trade_task_payment_mainline_p0_pay_v1_3'`,
      `ALTER TABLE platform_service_fee_charges
       ADD COLUMN IF NOT EXISTS fee_rate_snapshot_hash varchar(128) NOT NULL DEFAULT ''`,
      `ALTER TABLE platform_service_fee_charges
       ADD COLUMN IF NOT EXISTS fee_calculated_at timestamptz`,
      `UPDATE platform_service_fee_charges charge
       SET fee_rate_label = COALESCE(auth.fee_rate_label, charge.fee_rate_label),
           fee_rate_source = COALESCE(auth.fee_rate_source, charge.fee_rate_source),
           membership_tier_snapshot = COALESCE(auth.membership_tier_snapshot, charge.membership_tier_snapshot),
           fee_rate_rule_version = COALESCE(auth.fee_rate_rule_version, charge.fee_rate_rule_version),
           fee_rate_snapshot_hash = COALESCE(NULLIF(auth.fee_rate_snapshot_hash, ''), auth.rule_snapshot_hash, charge.fee_rate_snapshot_hash),
           fee_calculated_at = COALESCE(auth.fee_calculated_at, auth.agreed_at, charge.created_at)
       FROM platform_service_fee_authorizations auth
       WHERE charge.authorization_id = auth.id`
    ]
  },
  {
    key: '20260604_platform_pricing_sp1_kernel_normalization',
    statements: [
      `ALTER TABLE inquiry_quote_deposits
       ADD COLUMN IF NOT EXISTS withheld_at timestamptz`,
      `ALTER TABLE inquiry_quote_deposits
       ADD COLUMN IF NOT EXISTS withhold_reason_code varchar(96) NOT NULL DEFAULT ''`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS bid_participation_request_id varchar(64)`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS bidder_organization_id varchar(64)`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS authorization_quota_amount numeric(12,2)`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS charged_amount_used numeric(12,2) NOT NULL DEFAULT 0`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS released_amount numeric(12,2) NOT NULL DEFAULT 0`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS frozen_at timestamptz`,
      `CREATE INDEX IF NOT EXISTS idx_platform_service_fee_auth_bid_participation_request
       ON platform_service_fee_authorizations (bid_participation_request_id)`,
      `CREATE INDEX IF NOT EXISTS idx_platform_service_fee_auth_project_bidder
       ON platform_service_fee_authorizations (task_id, bidder_organization_id)`,
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_platform_service_fee_auth_one_active_project_bidder
       ON platform_service_fee_authorizations (task_id, bidder_organization_id)
       WHERE bidder_organization_id IS NOT NULL
         AND status IN ('pending_freeze', 'frozen', 'release_pending', 'charge_pending')`,
      `ALTER TABLE platform_service_fee_charges
       ADD COLUMN IF NOT EXISTS base_fee_amount numeric(12,2)`,
      `ALTER TABLE platform_service_fee_charges
       ADD COLUMN IF NOT EXISTS membership_discount_rate numeric(8,4)`,
      `ALTER TABLE platform_service_fee_charges
       ADD COLUMN IF NOT EXISTS cap_amount numeric(12,2)`,
      `ALTER TABLE platform_service_fee_charges
       ADD COLUMN IF NOT EXISTS released_remainder_amount numeric(12,2)`,
      `DO $$
       BEGIN
         ALTER TABLE inquiry_quote_deposits DROP CONSTRAINT IF EXISTS chk_inquiry_quote_deposits_status;
         ALTER TABLE inquiry_quote_deposits
           ADD CONSTRAINT chk_inquiry_quote_deposits_status
           CHECK (status IN (
             'pending_payment',
             'paid',
             'refund_pending',
             'refunded',
             'withheld',
             'deducted',
             'dispute_hold',
             'cancelled',
             'failed',
             'expired'
           ));
       END $$`,
      `DO $$
       BEGIN
         ALTER TABLE platform_service_fee_authorizations DROP CONSTRAINT IF EXISTS chk_platform_service_fee_auth_status;
         ALTER TABLE platform_service_fee_authorizations
           ADD CONSTRAINT chk_platform_service_fee_auth_status
           CHECK (status IN (
             'pending_freeze',
             'frozen',
             'release_pending',
             'released',
             'charge_pending',
             'pending_authorization',
             'authorized',
             'authorization_released',
             'pending_contract_confirm',
             'charged',
             'refund_pending',
             'refunded',
             'breach_hold',
             'cancelled',
             'failed',
             'expired'
           ));
       END $$`,
      `DO $$
       BEGIN
         ALTER TABLE contract_confirmations DROP CONSTRAINT IF EXISTS chk_contract_confirmations_status;
         ALTER TABLE contract_confirmations
           ADD CONSTRAINT chk_contract_confirmations_status
           CHECK (contract_status IN (
             'pending_counterparty_confirm',
             'confirmed_deal',
             'failed',
             'pending_counterparty',
             'confirmed',
             'cancelled'
           ));
       END $$`,
      `DO $$
       BEGIN
         ALTER TABLE platform_service_fee_charges DROP CONSTRAINT IF EXISTS chk_platform_service_fee_charges_status;
         ALTER TABLE platform_service_fee_charges
           ADD CONSTRAINT chk_platform_service_fee_charges_status
           CHECK (charge_status IN (
             'charge_pending',
             'pending_charge',
             'charged',
             'charge_failed',
             'refund_pending',
             'refunded',
             'cancelled'
           ));
       END $$`,
      `DO $$
       BEGIN
         ALTER TABLE payment_orders DROP CONSTRAINT IF EXISTS chk_payment_orders_business_type;
         ALTER TABLE payment_orders
           ADD CONSTRAINT chk_payment_orders_business_type
           CHECK (business_type IN (
             'project_authenticity_sincerity_payment',
             'project_authenticity_sincerity_refund',
             'bid_service_fee_authorization_freeze',
             'bid_service_fee_authorization_release',
             'platform_service_fee_charge',
             'platform_service_fee_authorization',
             'inquiry_deposit'
           ));
       END $$`
    ]
  },
  {
    key: '20260605_p0_pay_membership_discount_snapshot_truth',
    statements: [
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS base_fee_amount numeric(12,2)`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS membership_discount_rate numeric(8,4)`,
      `ALTER TABLE platform_service_fee_authorizations
       ADD COLUMN IF NOT EXISTS cap_amount numeric(12,2)`,
      `UPDATE platform_service_fee_authorizations
       SET fee_rate_label = '基础平台定价规则'
       WHERE fee_rate_label IN ('默认费率 3.0%', '免费认证企业 3.0%')`,
      `UPDATE platform_service_fee_authorizations
       SET fee_rate_label = '标准会员 9折（作用于 baseFeeAmount）'
       WHERE fee_rate_label = '标准会员 2.5%'`,
      `UPDATE platform_service_fee_authorizations
       SET fee_rate_label = '专业会员 8折（作用于 baseFeeAmount）'
       WHERE fee_rate_label = '专业会员 2.0%'`,
      `UPDATE platform_service_fee_charges
       SET fee_rate_label = '基础平台定价规则'
       WHERE fee_rate_label IN ('默认费率 3.0%', '免费认证企业 3.0%')`,
      `UPDATE platform_service_fee_charges
       SET fee_rate_label = '标准会员 9折（作用于 baseFeeAmount）'
       WHERE fee_rate_label = '标准会员 2.5%'`,
      `UPDATE platform_service_fee_charges
       SET fee_rate_label = '专业会员 8折（作用于 baseFeeAmount）'
       WHERE fee_rate_label = '专业会员 2.0%'`
    ]
  }
];

export const membershipPurchaseMigrations = [
  {
    key: '20260501_membership_direct_purchase_minimum_loop',
    statements: [
      `CREATE TABLE IF NOT EXISTS membership_orders (
        id varchar(64) PRIMARY KEY,
        organization_id varchar(64) NOT NULL,
        created_by_user_id varchar(64) NOT NULL,
        sku_code varchar(64) NOT NULL,
        sku_name varchar(128) NOT NULL,
        membership_tier varchar(32) NOT NULL,
        duration_months integer NOT NULL,
        payable_amount numeric(12,2) NOT NULL,
        currency varchar(8) NOT NULL DEFAULT 'CNY',
        order_status varchar(32) NOT NULL,
        payment_status varchar(32) NOT NULL,
        entitlement_status varchar(32) NOT NULL,
        payment_order_id varchar(64),
        paid_membership_id varchar(64),
        order_expires_at timestamptz,
        effective_at timestamptz,
        expires_at timestamptz,
        failure_reason_code varchar(96) NOT NULL DEFAULT '',
        request_id varchar(64) NOT NULL DEFAULT '',
        trace_id varchar(64) NOT NULL DEFAULT '',
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT chk_membership_orders_tier
          CHECK (membership_tier IN ('standard', 'professional')),
        CONSTRAINT chk_membership_orders_currency
          CHECK (currency = 'CNY'),
        CONSTRAINT chk_membership_orders_order_status
          CHECK (order_status IN (
            'created',
            'pending_pay',
            'paying',
            'paid',
            'granting',
            'active',
            'closed',
            'failed'
          )),
        CONSTRAINT chk_membership_orders_payment_status
          CHECK (payment_status IN (
            'not_started',
            'pending',
            'succeeded',
            'failed',
            'closed',
            'unknown'
          )),
        CONSTRAINT chk_membership_orders_entitlement_status
          CHECK (entitlement_status IN (
            'not_granted',
            'granting',
            'active',
            'grant_failed',
            'expired'
          ))
      )`,
      `CREATE INDEX IF NOT EXISTS idx_membership_orders_org_updated
       ON membership_orders (organization_id, updated_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_membership_orders_status_updated
       ON membership_orders (order_status, updated_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_membership_orders_payment_order
       ON membership_orders (payment_order_id)`,
      `CREATE INDEX IF NOT EXISTS idx_membership_orders_paid_membership
       ON membership_orders (paid_membership_id)`,
      `DO $$
       BEGIN
         IF to_regclass('payment_orders') IS NOT NULL THEN
           ALTER TABLE payment_orders DROP CONSTRAINT IF EXISTS chk_payment_orders_business_type;
           ALTER TABLE payment_orders
             ADD CONSTRAINT chk_payment_orders_business_type
             CHECK (business_type IN (
               'project_authenticity_sincerity_payment',
               'project_authenticity_sincerity_refund',
               'bid_service_fee_authorization_freeze',
               'bid_service_fee_authorization_release',
               'platform_service_fee_charge',
               'platform_service_fee_authorization',
               'inquiry_deposit',
               'membership_direct_purchase'
             ));
         END IF;
       END $$`
    ]
  }
];

export const projectExitGovernancePhase1Migrations = [
  {
    key: '20260603_project_exit_governance_phase1_truth',
    statements: [
      `CREATE TABLE IF NOT EXISTS project_exit_cases (
        id varchar(64) PRIMARY KEY,
        project_id varchar(64) NOT NULL,
        order_id varchar(64),
        contract_id varchar(64),
        exit_type varchar(48) NOT NULL,
        status varchar(48) NOT NULL,
        initiator_organization_id varchar(64) NOT NULL,
        counterparty_organization_id varchar(64),
        breach_party varchar(32),
        reason_code varchar(64) NOT NULL,
        reason_text text,
        credit_impact_candidate boolean NOT NULL DEFAULT false,
        no_automatic_penalty_confirmed boolean NOT NULL DEFAULT true,
        requested_at timestamptz,
        responded_at timestamptz,
        closed_at timestamptz,
        request_id varchar(64) NOT NULL DEFAULT '',
        trace_id varchar(64) NOT NULL DEFAULT '',
        created_by_user_id varchar(64) NOT NULL DEFAULT '',
        responded_by_user_id varchar(64),
        created_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )`,
      `CREATE INDEX IF NOT EXISTS idx_project_exit_cases_project_created
       ON project_exit_cases (project_id, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_project_exit_cases_project_status
       ON project_exit_cases (project_id, status)`,
      `CREATE INDEX IF NOT EXISTS idx_project_exit_cases_initiator_created
       ON project_exit_cases (initiator_organization_id, created_at DESC)`,
      `CREATE INDEX IF NOT EXISTS idx_project_exit_cases_counterparty_created
       ON project_exit_cases (counterparty_organization_id, created_at DESC)`
    ]
  }
];

export const serverMigrations = [
  ...enterpriseHubMigrations,
  ...projectPublishCorridorMigrations,
  ...membershipEntitlementMigrations,
  ...creditDepositTransactionGuaranteeMigrations,
  ...paymentBillingMigrations,
  ...authPublicLoginMigrations,
  ...currentSessionScopeMigrations,
  ...personalMinimalEditMigrations,
  ...profileSafetyP0Migrations,
  ...forumReportP0Migrations,
  ...forumInteractionTruthMigrations,
  ...blockP0AMigrations,
  ...governancePenaltyP1AMigrations,
  ...governanceAppealP1AMigrations,
  ...exhibitionReportCaseP0Migrations,
  ...governanceRescanP2AMigrations,
  ...certificationRevalidationMigrations,
  ...aiReviewGatewayP1AMigrations,
  ...projectTransactionSkeletonP0Migrations,
  ...bidSubmitQuoteAmountRepairMigrations,
  ...bidSeatTruthBackfillMigrations,
  ...bidDuplicateSubmitRepairMigrations,
  ...bidSubmissionSnapshotAttachmentTruthMigrations,
  ...bidAwardBridgeCompletionMigrations,
  ...bidToCompletedOrderFulfillmentMigrations,
  ...projectOrderTruthMigrations,
  ...authWhitelistTestSessionMigrations,
  ...authLoginLegalConsentMigrations,
  ...authPasswordCredentialMigrations,
  ...projectAttachmentCorridorP1Migrations,
  ...projectPublicResourceDownloadZoneMigrations,
  ...certificationLicenseFieldCollectionMigrations,
  ...enterpriseDisplayTruthRepairMigrations,
  ...personalCertificationDualGateMigrations,
  ...tradingImRoundAMigrations,
  ...projectNameAccessRequestMigrations,
  ...bidParticipationRequestMigrations,
  ...projectCommunicationAlbumMigrations,
  ...projectConversationWorkbenchV1Migrations,
  ...projectCommunicationNotificationPreviewV1Migrations,
  ...projectCounterpartyRatingMigrations,
  ...projectExitGovernancePhase1Migrations,
  ...p0PayMigrations,
  ...membershipPurchaseMigrations
];
