// Client-specific legacy tables that live in production. Defined here so drizzle-kit push does not drop them. Not OSS-generic.

import {
  pgTable,
  serial,
  varchar,
  text,
  integer,
  boolean,
  timestamp,
  jsonb,
  json,
  date,
  uuid,
  index,
  uniqueIndex,
} from 'drizzle-orm/pg-core';
import { clientWebsites } from './sites';
import { products } from './store';

// ─── LEGACY PRODUCT DESIGNER ────────────────────────────────────────────────
// These three tables shipped in the public baseline before the replacement
// product designer was introduced. They remain in every database created from
// drizzle/0000_baseline_2026_06_25.sql and may still contain customer designs.
// Keep their exact shape in the Drizzle catalogue so generate/push treats them
// as retained compatibility data instead of proposing destructive drops. New
// code must continue to use productDesigns/designLibraryAssets/productSides;
// these declarations exist only to make that retention deliberate. SHDB-002.

export const legacyDesigns = pgTable('designs', {
  id: uuid('id').defaultRandom().primaryKey(),
  websiteId: integer('website_id').notNull().references(() => clientWebsites.id, { onDelete: 'cascade' }),
  productId: integer('product_id').notNull().references(() => products.id, { onDelete: 'cascade' }),
  customerId: integer('customer_id'),
  sessionId: varchar('session_id', { length: 255 }),
  name: varchar('name', { length: 255 }).default('Untitled design').notNull(),
  layersBySurface: jsonb('layers_by_surface').default({}).notNull(),
  canvasSize: jsonb('canvas_size').default({ width: 800, height: 600, dpi: 72 }).notNull(),
  thumbnailUrl: varchar('thumbnail_url', { length: 500 }),
  renderedUrl: varchar('rendered_url', { length: 500 }),
  status: varchar('status', { length: 20 }).default('draft').notNull(),
  isTemplate: boolean('is_template').default(false).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (t) => [
  index('designs_website_idx').on(t.websiteId),
  index('designs_customer_idx').on(t.customerId),
  index('designs_session_idx').on(t.sessionId),
  index('designs_product_idx').on(t.productId),
  index('designs_template_idx').on(t.isTemplate),
]);

export const legacyDesignAssets = pgTable('design_assets', {
  id: serial('id').primaryKey(),
  designId: uuid('design_id').notNull().references(() => legacyDesigns.id, { onDelete: 'cascade' }),
  url: varchar('url', { length: 500 }).notNull(),
  storedFilename: varchar('stored_filename', { length: 255 }),
  originalFilename: varchar('original_filename', { length: 255 }),
  mimeType: varchar('mime_type', { length: 80 }),
  width: integer('width'),
  height: integer('height'),
  fileSize: integer('file_size'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const legacyProductDesignSurfaces = pgTable('product_design_surfaces', {
  id: serial('id').primaryKey(),
  productId: integer('product_id').notNull().references(() => products.id, { onDelete: 'cascade' }),
  name: varchar('name', { length: 80 }).notNull(),
  slug: varchar('slug', { length: 80 }).notNull(),
  displayOrder: integer('display_order').default(0).notNull(),
  mockupImage: varchar('mockup_image', { length: 500 }).notNull(),
  canvasWidth: integer('canvas_width').default(800).notNull(),
  canvasHeight: integer('canvas_height').default(600).notNull(),
  printAreaX: integer('print_area_x').default(100).notNull(),
  printAreaY: integer('print_area_y').default(100).notNull(),
  printAreaWidth: integer('print_area_width').default(600).notNull(),
  printAreaHeight: integer('print_area_height').default(400).notNull(),
  printDpi: integer('print_dpi').default(300).notNull(),
  active: boolean('active').default(true).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (t) => [
  uniqueIndex('product_design_surfaces_product_slug_idx').on(t.productId, t.slug),
]);

// ─── MAGAMOMMY ────────────────────────────────────────────────────────────────

export const magamommyBriefs = pgTable('magamommy_briefs', {
  id: serial('id').primaryKey(),
  websiteId: integer('website_id').notNull(),
  weekOf: date('week_of').notNull(),
  topics: jsonb('topics').default([]).notNull(),
  rawModelResponse: text('raw_model_response'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (t) => [
  index('magamommy_briefs_website_idx').on(t.websiteId),
  index('magamommy_briefs_week_idx').on(t.weekOf),
]);

export const magamommyConcepts = pgTable('magamommy_concepts', {
  id: serial('id').primaryKey(),
  websiteId: integer('website_id').notNull(),
  briefId: integer('brief_id').notNull(),
  topicSlug: varchar('topic_slug', { length: 120 }).notNull(),
  slogan: varchar('slogan', { length: 120 }).notNull(),
  tagline: text('tagline').notNull(),
  visualPrompt: text('visual_prompt').notNull(),
  palette: jsonb('palette').default([]).notNull(),
  placement: varchar('placement', { length: 20 }).default('front').notNull(),
  style: varchar('style', { length: 20 }).default('bold').notNull(),
  alternatives: jsonb('alternatives').default([]).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (t) => [
  index('magamommy_concepts_brief_idx').on(t.briefId),
  index('magamommy_concepts_website_idx').on(t.websiteId),
]);

export const magamommyDrops = pgTable('magamommy_drops', {
  id: serial('id').primaryKey(),
  websiteId: integer('website_id').notNull(),
  weekOf: date('week_of').notNull(),
  status: varchar('status', { length: 20 }).default('pending').notNull(),
  briefId: integer('brief_id'),
  conceptId: integer('concept_id'),
  designId: uuid('design_id'),
  productId: integer('product_id'),
  error: text('error'),
  errorStage: varchar('error_stage', { length: 30 }),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (t) => [
  uniqueIndex('magamommy_drops_site_week_uidx').on(t.websiteId, t.weekOf),
  index('magamommy_drops_status_idx').on(t.status),
]);

// ─── PHILAPRINTS ─────────────────────────────────────────────────────────────

export const philaprintsDesignAssets = pgTable('philaprints_design_assets', {
  id: serial('id').primaryKey(),
  websiteId: integer('website_id').notNull(),
  type: varchar('type', { length: 20 }).notNull(),
  category: varchar('category', { length: 100 }),
  name: varchar('name', { length: 255 }).notNull(),
  iconName: varchar('icon_name', { length: 100 }),
  iconPack: varchar('icon_pack', { length: 20 }),
  imageUrl: varchar('image_url', { length: 500 }),
  tags: json('tags').default([]),
  order: integer('order').default(0).notNull(),
  active: boolean('active').default(true).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

// ─── POSTCAPTAIN ─────────────────────────────────────────────────────────────

export const postcaptainBriefs = pgTable('postcaptain_briefs', {
  id: serial('id').primaryKey(),
  clientId: integer('client_id').notNull(),
  runId: integer('run_id').notNull(),
  topic: varchar('topic', { length: 255 }).notNull(),
  focus: text('focus'),
  body: text('body').notNull(),
  sources: jsonb('sources').default([]).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  meta: jsonb('meta').default({}).notNull(),
}, (t) => [
  index('postcaptain_briefs_client_idx').on(t.clientId),
  index('postcaptain_briefs_run_idx').on(t.runId),
]);

export const postcaptainDrafts = pgTable('postcaptain_drafts', {
  id: serial('id').primaryKey(),
  clientId: integer('client_id').notNull(),
  runId: integer('run_id').notNull(),
  briefId: integer('brief_id'),
  title: varchar('title', { length: 255 }).notNull(),
  body: text('body').notNull(),
  status: varchar('status', { length: 20 }).default('draft').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (t) => [
  index('postcaptain_drafts_client_idx').on(t.clientId),
  index('postcaptain_drafts_run_idx').on(t.runId),
]);
