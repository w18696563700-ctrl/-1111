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

export const serverMigrations = [
  ...enterpriseHubMigrations,
  ...projectPublishCorridorMigrations,
  ...membershipEntitlementMigrations,
  ...creditDepositTransactionGuaranteeMigrations,
  ...paymentBillingMigrations,
  ...authPublicLoginMigrations,
  ...personalMinimalEditMigrations,
  ...profileSafetyP0Migrations,
  ...forumReportP0Migrations,
  ...blockP0AMigrations
];
