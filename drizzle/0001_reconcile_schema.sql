CREATE TYPE "public"."path_chart_edge_kind" AS ENUM('nav', 'data');--> statement-breakpoint
CREATE TYPE "public"."path_chart_node_kind" AS ENUM('screen', 'component', 'api', 'schema', 'service', 'test', 'job', 'infra');--> statement-breakpoint
CREATE TYPE "public"."path_chart_node_status" AS ENUM('planned', 'scaffolded', 'wired', 'styled', 'tested', 'shipped', 'blocked', 'error');--> statement-breakpoint
CREATE TYPE "public"."path_chart_status" AS ENUM('active', 'archived');--> statement-breakpoint
CREATE TYPE "public"."agent_flow_run_status" AS ENUM('running', 'waiting', 'succeeded', 'failed', 'abandoned');--> statement-breakpoint
CREATE TABLE "site_redirects" (
	"id" serial PRIMARY KEY NOT NULL,
	"website_id" integer NOT NULL,
	"from_path" varchar(500) NOT NULL,
	"to_path" varchar(2000) NOT NULL,
	"status_code" integer DEFAULT 301 NOT NULL,
	"enabled" boolean DEFAULT true NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "automation_jobs" (
	"id" serial PRIMARY KEY NOT NULL,
	"client_id" integer NOT NULL,
	"event" varchar(100) NOT NULL,
	"user_id" integer DEFAULT 0 NOT NULL,
	"payload" json NOT NULL,
	"status" varchar(20) DEFAULT 'pending' NOT NULL,
	"attempt_count" integer DEFAULT 0 NOT NULL,
	"next_retry_at" timestamp with time zone,
	"error" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"processed_at" timestamp
);
--> statement-breakpoint
CREATE TABLE "linkedin_posts" (
	"id" serial PRIMARY KEY NOT NULL,
	"client_id" integer NOT NULL,
	"user_id" integer NOT NULL,
	"text" varchar(3000) NOT NULL,
	"media_type" varchar(16) DEFAULT 'none' NOT NULL,
	"media_url" text,
	"media_asset_urn" text,
	"link_in_comment" text,
	"status" varchar(16) DEFAULT 'draft' NOT NULL,
	"scheduled_at" timestamp with time zone,
	"published_at" timestamp with time zone,
	"linkedin_post_id" text,
	"permalink" text,
	"error" text,
	"created_by_user_id" integer,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "linkedin_user_connections" (
	"id" serial PRIMARY KEY NOT NULL,
	"client_id" integer NOT NULL,
	"user_id" integer NOT NULL,
	"member_urn" varchar(128) NOT NULL,
	"linkedin_name" varchar(320),
	"access_token_encrypted" text NOT NULL,
	"refresh_token_encrypted" text,
	"expires_at" timestamp with time zone NOT NULL,
	"refresh_token_expires_at" timestamp with time zone,
	"scopes" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"revoked_at" timestamp with time zone,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "agent_action_captures" (
	"id" serial PRIMARY KEY NOT NULL,
	"client_id" integer NOT NULL,
	"audit_log_id" integer,
	"tool_name" varchar(120) NOT NULL,
	"key_id" integer,
	"user_id" integer,
	"ciphertext" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "workflow_run_steps" (
	"id" serial PRIMARY KEY NOT NULL,
	"run_id" integer NOT NULL,
	"client_id" integer NOT NULL,
	"node_id" text NOT NULL,
	"action" text NOT NULL,
	"status" varchar(20) DEFAULT 'pending' NOT NULL,
	"attempt_count" integer DEFAULT 0 NOT NULL,
	"next_retry_at" timestamp,
	"idempotency_key" text,
	"input" json,
	"result" json,
	"error" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "path_chart_claims" (
	"id" serial PRIMARY KEY NOT NULL,
	"chart_id" integer NOT NULL,
	"node_id" integer NOT NULL,
	"agent_label" varchar(120) NOT NULL,
	"intent" text,
	"files" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"released_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "path_chart_edges" (
	"id" serial PRIMARY KEY NOT NULL,
	"chart_id" integer NOT NULL,
	"source_node_id" integer NOT NULL,
	"target_node_id" integer NOT NULL,
	"kind" "path_chart_edge_kind" NOT NULL,
	"label" varchar(120),
	"meta" jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "path_chart_events" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"chart_id" integer NOT NULL,
	"event_type" varchar(50) NOT NULL,
	"payload" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"agent_label" varchar(120),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "path_chart_nodes" (
	"id" serial PRIMARY KEY NOT NULL,
	"chart_id" integer NOT NULL,
	"key" varchar(120) NOT NULL,
	"parent_node_id" integer,
	"kind" "path_chart_node_kind" NOT NULL,
	"label" varchar(200) NOT NULL,
	"route_path" varchar(300),
	"file_path" varchar(500),
	"status" "path_chart_node_status" DEFAULT 'planned' NOT NULL,
	"meta" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"position" jsonb,
	"last_verified_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "path_charts" (
	"id" serial PRIMARY KEY NOT NULL,
	"project_id" integer NOT NULL,
	"title" varchar(200) NOT NULL,
	"description" text,
	"app_label" varchar(120),
	"status" "path_chart_status" DEFAULT 'active' NOT NULL,
	"created_by_agent" varchar(120),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "magamommy_briefs" (
	"id" serial PRIMARY KEY NOT NULL,
	"website_id" integer NOT NULL,
	"week_of" date NOT NULL,
	"topics" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"raw_model_response" text,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "magamommy_concepts" (
	"id" serial PRIMARY KEY NOT NULL,
	"website_id" integer NOT NULL,
	"brief_id" integer NOT NULL,
	"topic_slug" varchar(120) NOT NULL,
	"slogan" varchar(120) NOT NULL,
	"tagline" text NOT NULL,
	"visual_prompt" text NOT NULL,
	"palette" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"placement" varchar(20) DEFAULT 'front' NOT NULL,
	"style" varchar(20) DEFAULT 'bold' NOT NULL,
	"alternatives" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "magamommy_drops" (
	"id" serial PRIMARY KEY NOT NULL,
	"website_id" integer NOT NULL,
	"week_of" date NOT NULL,
	"status" varchar(20) DEFAULT 'pending' NOT NULL,
	"brief_id" integer,
	"concept_id" integer,
	"design_id" uuid,
	"product_id" integer,
	"error" text,
	"error_stage" varchar(30),
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "philaprints_design_assets" (
	"id" serial PRIMARY KEY NOT NULL,
	"website_id" integer NOT NULL,
	"type" varchar(20) NOT NULL,
	"category" varchar(100),
	"name" varchar(255) NOT NULL,
	"icon_name" varchar(100),
	"icon_pack" varchar(20),
	"image_url" varchar(500),
	"tags" json DEFAULT '[]'::json,
	"order" integer DEFAULT 0 NOT NULL,
	"active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "postcaptain_briefs" (
	"id" serial PRIMARY KEY NOT NULL,
	"client_id" integer NOT NULL,
	"run_id" integer NOT NULL,
	"topic" varchar(255) NOT NULL,
	"focus" text,
	"body" text NOT NULL,
	"sources" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"meta" jsonb DEFAULT '{}'::jsonb NOT NULL
);
--> statement-breakpoint
CREATE TABLE "postcaptain_drafts" (
	"id" serial PRIMARY KEY NOT NULL,
	"client_id" integer NOT NULL,
	"run_id" integer NOT NULL,
	"brief_id" integer,
	"title" varchar(255) NOT NULL,
	"body" text NOT NULL,
	"status" varchar(20) DEFAULT 'draft' NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "agent_flow_run_events" (
	"id" serial PRIMARY KEY NOT NULL,
	"run_id" integer NOT NULL,
	"type" varchar(32) NOT NULL,
	"node_id" varchar(64),
	"status" varchar(16),
	"summary" text,
	"model" varchar(32),
	"input_tokens" integer,
	"output_tokens" integer,
	"duration_ms" integer,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "agent_flow_runs" (
	"id" serial PRIMARY KEY NOT NULL,
	"flow_id" integer NOT NULL,
	"project_id" integer NOT NULL,
	"client_id" integer NOT NULL,
	"status" "agent_flow_run_status" DEFAULT 'running' NOT NULL,
	"graph" jsonb NOT NULL,
	"parent_run_id" integer,
	"parent_node_id" varchar(64),
	"depth" integer DEFAULT 0 NOT NULL,
	"input_tokens" integer DEFAULT 0 NOT NULL,
	"output_tokens" integer DEFAULT 0 NOT NULL,
	"started_by" integer,
	"started_at" timestamp with time zone DEFAULT now() NOT NULL,
	"finished_at" timestamp with time zone,
	"last_event_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "agent_flows" (
	"id" serial PRIMARY KEY NOT NULL,
	"project_id" integer NOT NULL,
	"client_id" integer NOT NULL,
	"name" varchar(255) NOT NULL,
	"description" text,
	"status" varchar(20) DEFAULT 'draft' NOT NULL,
	"graph" jsonb DEFAULT '{"nodes":[],"edges":[]}'::jsonb NOT NULL,
	"created_by" integer,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "internal_jobs" (
	"id" serial PRIMARY KEY NOT NULL,
	"client_id" integer NOT NULL,
	"type" varchar(60) NOT NULL,
	"payload" json NOT NULL,
	"status" varchar(20) DEFAULT 'pending' NOT NULL,
	"attempt_count" integer DEFAULT 0 NOT NULL,
	"next_retry_at" timestamp with time zone,
	"error" text,
	"dedupe_key" varchar(200),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"processed_at" timestamp with time zone,
	CONSTRAINT "internal_jobs_dedupe_key_unique" UNIQUE("dedupe_key")
);
--> statement-breakpoint
CREATE TABLE "seo_crawl_pages" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"run_id" integer NOT NULL,
	"project_id" integer NOT NULL,
	"client_id" integer NOT NULL,
	"url" varchar(2048) NOT NULL,
	"url_hash" varchar(64) NOT NULL,
	"http_status" integer,
	"final_url" varchar(2048),
	"redirect_chain" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"content_type" varchar(128),
	"response_time_ms" integer,
	"response_bytes" integer,
	"depth" integer DEFAULT 0 NOT NULL,
	"discovered_from" varchar(16) DEFAULT 'link' NOT NULL,
	"indexable" boolean,
	"indexability_reason" varchar(64),
	"canonical_url" varchar(2048),
	"title" text,
	"meta_description" text,
	"h1" text,
	"h1_count" integer DEFAULT 0 NOT NULL,
	"word_count" integer DEFAULT 0 NOT NULL,
	"lang" varchar(16),
	"content_hash" varchar(64),
	"internal_links_count" integer DEFAULT 0 NOT NULL,
	"external_links_count" integer DEFAULT 0 NOT NULL,
	"nofollow_links_count" integer DEFAULT 0 NOT NULL,
	"images_count" integer DEFAULT 0 NOT NULL,
	"images_missing_alt" integer DEFAULT 0 NOT NULL,
	"meta" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"internal_rank" real,
	"incoming_links" integer DEFAULT 0 NOT NULL,
	"orphan" boolean DEFAULT false NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "seo_crawl_runs" (
	"id" serial PRIMARY KEY NOT NULL,
	"project_id" integer NOT NULL,
	"client_id" integer NOT NULL,
	"status" varchar(16) DEFAULT 'queued' NOT NULL,
	"pages_crawled" integer DEFAULT 0 NOT NULL,
	"state" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"health_score" integer,
	"critical_count" integer DEFAULT 0 NOT NULL,
	"warning_count" integer DEFAULT 0 NOT NULL,
	"notice_count" integer DEFAULT 0 NOT NULL,
	"stats" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"error" text,
	"started_at" timestamp with time zone,
	"heartbeat_at" timestamp with time zone,
	"finished_at" timestamp with time zone,
	"requested_by" integer,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "seo_gsc_page_daily" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"project_id" integer NOT NULL,
	"client_id" integer NOT NULL,
	"date" varchar(10) NOT NULL,
	"page" varchar(2048) NOT NULL,
	"clicks" integer DEFAULT 0 NOT NULL,
	"impressions" integer DEFAULT 0 NOT NULL,
	"ctr" real DEFAULT 0 NOT NULL,
	"position" real DEFAULT 0 NOT NULL
);
--> statement-breakpoint
CREATE TABLE "seo_gsc_query_daily" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"project_id" integer NOT NULL,
	"client_id" integer NOT NULL,
	"date" varchar(10) NOT NULL,
	"query" varchar(512) NOT NULL,
	"clicks" integer DEFAULT 0 NOT NULL,
	"impressions" integer DEFAULT 0 NOT NULL,
	"ctr" real DEFAULT 0 NOT NULL,
	"position" real DEFAULT 0 NOT NULL
);
--> statement-breakpoint
CREATE TABLE "seo_issues" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"run_id" integer NOT NULL,
	"project_id" integer NOT NULL,
	"client_id" integer NOT NULL,
	"page_id" bigint,
	"rule_id" varchar(64) NOT NULL,
	"category" varchar(32) NOT NULL,
	"severity" varchar(16) NOT NULL,
	"details" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "seo_page_links" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"run_id" integer NOT NULL,
	"client_id" integer NOT NULL,
	"from_page_id" bigint NOT NULL,
	"to_url" varchar(2048) NOT NULL,
	"to_url_hash" varchar(64) NOT NULL,
	"to_page_id" bigint,
	"anchor_text" varchar(512),
	"is_internal" boolean DEFAULT true NOT NULL,
	"nofollow" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE "seo_projects" (
	"id" serial PRIMARY KEY NOT NULL,
	"client_id" integer NOT NULL,
	"website_id" integer,
	"name" varchar(255) NOT NULL,
	"domain" varchar(255) NOT NULL,
	"start_url" varchar(500) NOT NULL,
	"max_pages" integer DEFAULT 200 NOT NULL,
	"max_depth" integer DEFAULT 5 NOT NULL,
	"settings" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"active" boolean DEFAULT true NOT NULL,
	"created_by" integer,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "seo_recommendations" (
	"id" serial PRIMARY KEY NOT NULL,
	"project_id" integer NOT NULL,
	"client_id" integer NOT NULL,
	"run_id" integer,
	"title" varchar(255) NOT NULL,
	"body" text NOT NULL,
	"impact" varchar(16) NOT NULL,
	"effort" varchar(16) NOT NULL,
	"confidence" real NOT NULL,
	"opportunity_score" real NOT NULL,
	"evidence" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"status" varchar(16) DEFAULT 'open' NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "automation_logs" DROP CONSTRAINT "automation_logs_rule_id_automation_rules_id_fk";
--> statement-breakpoint
ALTER TABLE "mcp_tool_calls" DROP CONSTRAINT "mcp_tool_calls_api_key_id_portal_api_keys_id_fk";
--> statement-breakpoint
ALTER TABLE "mcp_approval_links" DROP CONSTRAINT "mcp_approval_links_key_id_portal_api_keys_id_fk";
--> statement-breakpoint
ALTER TABLE "mcp_pending_changes" DROP CONSTRAINT "mcp_pending_changes_key_id_portal_api_keys_id_fk";
--> statement-breakpoint
ALTER TABLE "automation_logs" ALTER COLUMN "rule_id" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "automation_rules" ALTER COLUMN "schedule" SET DATA TYPE jsonb;--> statement-breakpoint
ALTER TABLE "surveys" ALTER COLUMN "scoring_config" SET DATA TYPE jsonb;--> statement-breakpoint
ALTER TABLE "portal_api_keys" ADD COLUMN "client_ids" json DEFAULT '[]'::json NOT NULL;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "password_history" jsonb DEFAULT '[]'::jsonb NOT NULL;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "mfa_enabled" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "totp_secret" text;--> statement-breakpoint
ALTER TABLE "client_websites" ADD COLUMN "cdn_cache_enabled" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "clients" ADD COLUMN "ai_chat_requires_approval" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "clients" ADD COLUMN "feature_flags" jsonb DEFAULT '[]'::jsonb NOT NULL;--> statement-breakpoint
ALTER TABLE "crm_contacts" ADD COLUMN "attribution" jsonb;--> statement-breakpoint
ALTER TABLE "crm_deal_comments" ADD COLUMN "parent_comment_id" integer;--> statement-breakpoint
ALTER TABLE "automation_rules" ADD COLUMN "requires_approval" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "brain_notes" ADD COLUMN "needs_review" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "order_items" ADD COLUMN "print_files" jsonb DEFAULT '{}'::jsonb;--> statement-breakpoint
ALTER TABLE "product_designs" ADD COLUMN "print_files" json DEFAULT '{}'::json;--> statement-breakpoint
ALTER TABLE "product_styles" ADD COLUMN "printful_variant_id" integer;--> statement-breakpoint
ALTER TABLE "surveys" ADD COLUMN "notify_user_ids" json DEFAULT '[]'::json NOT NULL;--> statement-breakpoint
ALTER TABLE "surveys" ADD COLUMN "last_digest_sent_at" timestamp;--> statement-breakpoint
ALTER TABLE "bookings" ADD COLUMN "slot_exclusive" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "mcp_tool_calls" ADD COLUMN "credential_kind" varchar(20);--> statement-breakpoint
ALTER TABLE "mcp_approval_links" ADD COLUMN "credential_kind" varchar(20);--> statement-breakpoint
ALTER TABLE "mcp_pending_changes" ADD COLUMN "credential_kind" varchar(20);--> statement-breakpoint
ALTER TABLE "oauth_access_tokens" ADD COLUMN "client_ids" json DEFAULT '[]'::json NOT NULL;--> statement-breakpoint
ALTER TABLE "oauth_access_tokens" ADD COLUMN "require_cms_approval" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "oauth_authorization_codes" ADD COLUMN "client_ids" json DEFAULT '[]'::json NOT NULL;--> statement-breakpoint
ALTER TABLE "oauth_refresh_tokens" ADD COLUMN "client_ids" json DEFAULT '[]'::json NOT NULL;--> statement-breakpoint
ALTER TABLE "site_redirects" ADD CONSTRAINT "site_redirects_website_id_client_websites_id_fk" FOREIGN KEY ("website_id") REFERENCES "public"."client_websites"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "automation_jobs" ADD CONSTRAINT "automation_jobs_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "linkedin_posts" ADD CONSTRAINT "linkedin_posts_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "linkedin_posts" ADD CONSTRAINT "linkedin_posts_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "linkedin_posts" ADD CONSTRAINT "linkedin_posts_created_by_user_id_users_id_fk" FOREIGN KEY ("created_by_user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "linkedin_user_connections" ADD CONSTRAINT "linkedin_user_connections_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "linkedin_user_connections" ADD CONSTRAINT "linkedin_user_connections_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_action_captures" ADD CONSTRAINT "agent_action_captures_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_action_captures" ADD CONSTRAINT "agent_action_captures_audit_log_id_agent_action_logs_id_fk" FOREIGN KEY ("audit_log_id") REFERENCES "public"."agent_action_logs"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_action_captures" ADD CONSTRAINT "agent_action_captures_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "workflow_run_steps" ADD CONSTRAINT "workflow_run_steps_run_id_workflow_runs_id_fk" FOREIGN KEY ("run_id") REFERENCES "public"."workflow_runs"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "workflow_run_steps" ADD CONSTRAINT "workflow_run_steps_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "path_chart_claims" ADD CONSTRAINT "path_chart_claims_chart_id_path_charts_id_fk" FOREIGN KEY ("chart_id") REFERENCES "public"."path_charts"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "path_chart_claims" ADD CONSTRAINT "path_chart_claims_node_id_path_chart_nodes_id_fk" FOREIGN KEY ("node_id") REFERENCES "public"."path_chart_nodes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "path_chart_edges" ADD CONSTRAINT "path_chart_edges_chart_id_path_charts_id_fk" FOREIGN KEY ("chart_id") REFERENCES "public"."path_charts"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "path_chart_edges" ADD CONSTRAINT "path_chart_edges_source_node_id_path_chart_nodes_id_fk" FOREIGN KEY ("source_node_id") REFERENCES "public"."path_chart_nodes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "path_chart_edges" ADD CONSTRAINT "path_chart_edges_target_node_id_path_chart_nodes_id_fk" FOREIGN KEY ("target_node_id") REFERENCES "public"."path_chart_nodes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "path_chart_events" ADD CONSTRAINT "path_chart_events_chart_id_path_charts_id_fk" FOREIGN KEY ("chart_id") REFERENCES "public"."path_charts"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "path_chart_nodes" ADD CONSTRAINT "path_chart_nodes_chart_id_path_charts_id_fk" FOREIGN KEY ("chart_id") REFERENCES "public"."path_charts"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "path_charts" ADD CONSTRAINT "path_charts_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_flow_run_events" ADD CONSTRAINT "agent_flow_run_events_run_id_agent_flow_runs_id_fk" FOREIGN KEY ("run_id") REFERENCES "public"."agent_flow_runs"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_flow_runs" ADD CONSTRAINT "agent_flow_runs_flow_id_agent_flows_id_fk" FOREIGN KEY ("flow_id") REFERENCES "public"."agent_flows"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_flow_runs" ADD CONSTRAINT "agent_flow_runs_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_flow_runs" ADD CONSTRAINT "agent_flow_runs_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_flow_runs" ADD CONSTRAINT "agent_flow_runs_parent_run_id_agent_flow_runs_id_fk" FOREIGN KEY ("parent_run_id") REFERENCES "public"."agent_flow_runs"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_flow_runs" ADD CONSTRAINT "agent_flow_runs_started_by_users_id_fk" FOREIGN KEY ("started_by") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_flows" ADD CONSTRAINT "agent_flows_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_flows" ADD CONSTRAINT "agent_flows_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "agent_flows" ADD CONSTRAINT "agent_flows_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "internal_jobs" ADD CONSTRAINT "internal_jobs_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_crawl_pages" ADD CONSTRAINT "seo_crawl_pages_run_id_seo_crawl_runs_id_fk" FOREIGN KEY ("run_id") REFERENCES "public"."seo_crawl_runs"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_crawl_pages" ADD CONSTRAINT "seo_crawl_pages_project_id_seo_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."seo_projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_crawl_pages" ADD CONSTRAINT "seo_crawl_pages_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_crawl_runs" ADD CONSTRAINT "seo_crawl_runs_project_id_seo_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."seo_projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_crawl_runs" ADD CONSTRAINT "seo_crawl_runs_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_crawl_runs" ADD CONSTRAINT "seo_crawl_runs_requested_by_users_id_fk" FOREIGN KEY ("requested_by") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_gsc_page_daily" ADD CONSTRAINT "seo_gsc_page_daily_project_id_seo_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."seo_projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_gsc_page_daily" ADD CONSTRAINT "seo_gsc_page_daily_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_gsc_query_daily" ADD CONSTRAINT "seo_gsc_query_daily_project_id_seo_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."seo_projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_gsc_query_daily" ADD CONSTRAINT "seo_gsc_query_daily_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_issues" ADD CONSTRAINT "seo_issues_run_id_seo_crawl_runs_id_fk" FOREIGN KEY ("run_id") REFERENCES "public"."seo_crawl_runs"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_issues" ADD CONSTRAINT "seo_issues_project_id_seo_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."seo_projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_issues" ADD CONSTRAINT "seo_issues_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_page_links" ADD CONSTRAINT "seo_page_links_run_id_seo_crawl_runs_id_fk" FOREIGN KEY ("run_id") REFERENCES "public"."seo_crawl_runs"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_page_links" ADD CONSTRAINT "seo_page_links_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_page_links" ADD CONSTRAINT "seo_page_links_from_page_id_seo_crawl_pages_id_fk" FOREIGN KEY ("from_page_id") REFERENCES "public"."seo_crawl_pages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_projects" ADD CONSTRAINT "seo_projects_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_projects" ADD CONSTRAINT "seo_projects_website_id_client_websites_id_fk" FOREIGN KEY ("website_id") REFERENCES "public"."client_websites"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_projects" ADD CONSTRAINT "seo_projects_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_recommendations" ADD CONSTRAINT "seo_recommendations_project_id_seo_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."seo_projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_recommendations" ADD CONSTRAINT "seo_recommendations_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "seo_recommendations" ADD CONSTRAINT "seo_recommendations_run_id_seo_crawl_runs_id_fk" FOREIGN KEY ("run_id") REFERENCES "public"."seo_crawl_runs"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "site_redirects_site_from_idx" ON "site_redirects" USING btree ("website_id","from_path");--> statement-breakpoint
CREATE INDEX "automation_jobs_pending_idx" ON "automation_jobs" USING btree ("status","created_at");--> statement-breakpoint
CREATE INDEX "linkedin_posts_status_scheduled_idx" ON "linkedin_posts" USING btree ("status","scheduled_at");--> statement-breakpoint
CREATE INDEX "linkedin_posts_client_idx" ON "linkedin_posts" USING btree ("client_id");--> statement-breakpoint
CREATE UNIQUE INDEX "linkedin_user_connections_client_user_unique" ON "linkedin_user_connections" USING btree ("client_id","user_id");--> statement-breakpoint
CREATE INDEX "agent_action_captures_client_created_idx" ON "agent_action_captures" USING btree ("client_id","created_at");--> statement-breakpoint
CREATE INDEX "workflow_run_steps_pending_idx" ON "workflow_run_steps" USING btree ("client_id","status","next_retry_at");--> statement-breakpoint
CREATE INDEX "path_chart_claims_chart_released_idx" ON "path_chart_claims" USING btree ("chart_id","released_at");--> statement-breakpoint
CREATE INDEX "path_chart_claims_files_gin_idx" ON "path_chart_claims" USING gin ("files");--> statement-breakpoint
CREATE UNIQUE INDEX "path_chart_edges_chart_source_target_kind_idx" ON "path_chart_edges" USING btree ("chart_id","source_node_id","target_node_id","kind");--> statement-breakpoint
CREATE INDEX "path_chart_events_chart_id_idx" ON "path_chart_events" USING btree ("chart_id","id");--> statement-breakpoint
CREATE UNIQUE INDEX "path_chart_nodes_chart_key_idx" ON "path_chart_nodes" USING btree ("chart_id","key");--> statement-breakpoint
CREATE INDEX "path_chart_nodes_chart_parent_idx" ON "path_chart_nodes" USING btree ("chart_id","parent_node_id");--> statement-breakpoint
CREATE INDEX "path_charts_project_status_idx" ON "path_charts" USING btree ("project_id","status");--> statement-breakpoint
CREATE INDEX "path_charts_project_updated_idx" ON "path_charts" USING btree ("project_id","updated_at");--> statement-breakpoint
CREATE INDEX "magamommy_briefs_website_idx" ON "magamommy_briefs" USING btree ("website_id");--> statement-breakpoint
CREATE INDEX "magamommy_briefs_week_idx" ON "magamommy_briefs" USING btree ("week_of");--> statement-breakpoint
CREATE INDEX "magamommy_concepts_brief_idx" ON "magamommy_concepts" USING btree ("brief_id");--> statement-breakpoint
CREATE INDEX "magamommy_concepts_website_idx" ON "magamommy_concepts" USING btree ("website_id");--> statement-breakpoint
CREATE UNIQUE INDEX "magamommy_drops_site_week_uidx" ON "magamommy_drops" USING btree ("website_id","week_of");--> statement-breakpoint
CREATE INDEX "magamommy_drops_status_idx" ON "magamommy_drops" USING btree ("status");--> statement-breakpoint
CREATE INDEX "postcaptain_briefs_client_idx" ON "postcaptain_briefs" USING btree ("client_id");--> statement-breakpoint
CREATE INDEX "postcaptain_briefs_run_idx" ON "postcaptain_briefs" USING btree ("run_id");--> statement-breakpoint
CREATE INDEX "postcaptain_drafts_client_idx" ON "postcaptain_drafts" USING btree ("client_id");--> statement-breakpoint
CREATE INDEX "postcaptain_drafts_run_idx" ON "postcaptain_drafts" USING btree ("run_id");--> statement-breakpoint
CREATE INDEX "agent_flow_run_events_run_idx" ON "agent_flow_run_events" USING btree ("run_id","id");--> statement-breakpoint
CREATE INDEX "agent_flow_runs_flow_idx" ON "agent_flow_runs" USING btree ("flow_id");--> statement-breakpoint
CREATE INDEX "agent_flow_runs_project_idx" ON "agent_flow_runs" USING btree ("project_id","started_at");--> statement-breakpoint
CREATE INDEX "agent_flow_runs_client_idx" ON "agent_flow_runs" USING btree ("client_id");--> statement-breakpoint
CREATE INDEX "agent_flow_runs_parent_idx" ON "agent_flow_runs" USING btree ("parent_run_id");--> statement-breakpoint
CREATE INDEX "agent_flows_project_idx" ON "agent_flows" USING btree ("project_id");--> statement-breakpoint
CREATE INDEX "agent_flows_client_idx" ON "agent_flows" USING btree ("client_id");--> statement-breakpoint
CREATE INDEX "internal_jobs_due_idx" ON "internal_jobs" USING btree ("status","next_retry_at");--> statement-breakpoint
CREATE UNIQUE INDEX "seo_crawl_pages_run_url_uq" ON "seo_crawl_pages" USING btree ("run_id","url_hash");--> statement-breakpoint
CREATE INDEX "seo_crawl_pages_project_idx" ON "seo_crawl_pages" USING btree ("project_id");--> statement-breakpoint
CREATE INDEX "seo_crawl_pages_client_idx" ON "seo_crawl_pages" USING btree ("client_id");--> statement-breakpoint
CREATE INDEX "seo_crawl_runs_project_idx" ON "seo_crawl_runs" USING btree ("project_id");--> statement-breakpoint
CREATE INDEX "seo_crawl_runs_client_idx" ON "seo_crawl_runs" USING btree ("client_id");--> statement-breakpoint
CREATE INDEX "seo_crawl_runs_status_idx" ON "seo_crawl_runs" USING btree ("status");--> statement-breakpoint
CREATE UNIQUE INDEX "seo_gsc_page_daily_uq" ON "seo_gsc_page_daily" USING btree ("project_id","date","page");--> statement-breakpoint
CREATE INDEX "seo_gsc_page_daily_client_idx" ON "seo_gsc_page_daily" USING btree ("client_id");--> statement-breakpoint
CREATE UNIQUE INDEX "seo_gsc_query_daily_uq" ON "seo_gsc_query_daily" USING btree ("project_id","date","query");--> statement-breakpoint
CREATE INDEX "seo_gsc_query_daily_client_idx" ON "seo_gsc_query_daily" USING btree ("client_id");--> statement-breakpoint
CREATE INDEX "seo_issues_run_idx" ON "seo_issues" USING btree ("run_id");--> statement-breakpoint
CREATE INDEX "seo_issues_run_rule_idx" ON "seo_issues" USING btree ("run_id","rule_id");--> statement-breakpoint
CREATE INDEX "seo_issues_client_idx" ON "seo_issues" USING btree ("client_id");--> statement-breakpoint
CREATE INDEX "seo_page_links_run_idx" ON "seo_page_links" USING btree ("run_id");--> statement-breakpoint
CREATE INDEX "seo_page_links_from_idx" ON "seo_page_links" USING btree ("from_page_id");--> statement-breakpoint
CREATE INDEX "seo_page_links_run_to_hash_idx" ON "seo_page_links" USING btree ("run_id","to_url_hash");--> statement-breakpoint
CREATE INDEX "seo_projects_client_idx" ON "seo_projects" USING btree ("client_id");--> statement-breakpoint
CREATE UNIQUE INDEX "seo_projects_client_domain_uq" ON "seo_projects" USING btree ("client_id","domain");--> statement-breakpoint
CREATE INDEX "seo_recommendations_project_idx" ON "seo_recommendations" USING btree ("project_id");--> statement-breakpoint
CREATE INDEX "seo_recommendations_client_idx" ON "seo_recommendations" USING btree ("client_id");--> statement-breakpoint
ALTER TABLE "automation_logs" ADD CONSTRAINT "automation_logs_rule_id_automation_rules_id_fk" FOREIGN KEY ("rule_id") REFERENCES "public"."automation_rules"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "bookings_exclusive_slot_idx" ON "bookings" USING btree ("booking_page_id","start_time") WHERE "bookings"."status" <> 'cancelled' AND "bookings"."slot_exclusive";