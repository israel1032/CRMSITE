/**
 * Proves that the journaled migrations reproduce the current Drizzle schema.
 * CI builds two disposable databases first: one with `db:migrate`, one with
 * `drizzle-kit push --force`, then points this script at both. Comparing the
 * PostgreSQL catalogue catches the orphaned-migration failure class that left
 * fresh self-host installs dozens of tables behind production. Physical column
 * order is intentionally ignored: ADD COLUMN appends while a fresh push emits
 * declaration order, and that difference has no query/runtime semantics.
 * SHDB-002.
 */

import postgres from 'postgres';

const migratedDatabaseUrl = process.env.MIGRATED_DATABASE_URL;
const schemaDatabaseUrl = process.env.SCHEMA_DATABASE_URL;

if (!migratedDatabaseUrl || !schemaDatabaseUrl) {
  console.error(
    '[migration-schema-drift] MIGRATED_DATABASE_URL and SCHEMA_DATABASE_URL are required.',
  );
  process.exit(1);
}

const CATALOG_QUERY = `
WITH objects AS (
  SELECT 'table|' || c.relname AS item
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public' AND c.relkind = 'r'

  UNION ALL

  SELECT 'column|' || c.relname || '|' || a.attname || '|'
      || format_type(a.atttypid, a.atttypmod) || '|'
      || a.attnotnull || '|'
      || COALESCE(pg_get_expr(d.adbin, d.adrelid), '')
  FROM pg_attribute a
  JOIN pg_class c ON c.oid = a.attrelid
  JOIN pg_namespace n ON n.oid = c.relnamespace
  LEFT JOIN pg_attrdef d ON d.adrelid = a.attrelid AND d.adnum = a.attnum
  WHERE n.nspname = 'public'
    AND c.relkind = 'r'
    AND a.attnum > 0
    AND NOT a.attisdropped

  UNION ALL

  SELECT 'enum|' || t.typname || '|' || e.enumsortorder || '|' || e.enumlabel
  FROM pg_type t
  JOIN pg_namespace n ON n.oid = t.typnamespace
  JOIN pg_enum e ON e.enumtypid = t.oid
  WHERE n.nspname = 'public'

  UNION ALL

  SELECT 'constraint|' || c.relname || '|' || con.conname || '|'
      || pg_get_constraintdef(con.oid, true)
  FROM pg_constraint con
  JOIN pg_class c ON c.oid = con.conrelid
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'

  UNION ALL

  SELECT 'index|' || tab.relname || '|' || idx.relname || '|'
      || pg_get_indexdef(idx.oid)
  FROM pg_index i
  JOIN pg_class idx ON idx.oid = i.indexrelid
  JOIN pg_class tab ON tab.oid = i.indrelid
  JOIN pg_namespace n ON n.oid = tab.relnamespace
  WHERE n.nspname = 'public'
)
SELECT item FROM objects ORDER BY item;
`;

async function readCatalogue(databaseUrl: string): Promise<Set<string>> {
  const sql = postgres(databaseUrl, { max: 1 });
  try {
    const rows = await sql.unsafe<{ item: string }[]>(CATALOG_QUERY);
    return new Set(rows.map((row) => row.item));
  } finally {
    await sql.end();
  }
}

const [migratedObjects, schemaObjects] = await Promise.all([
  readCatalogue(migratedDatabaseUrl),
  readCatalogue(schemaDatabaseUrl),
]);

const onlyMigrated = [...migratedObjects].filter((item) => !schemaObjects.has(item));
const onlySchema = [...schemaObjects].filter((item) => !migratedObjects.has(item));

if (onlyMigrated.length || onlySchema.length) {
  console.error(
    `[migration-schema-drift] FAIL: ${onlyMigrated.length} only in migrations; ${onlySchema.length} only in schema.`,
  );
  for (const item of onlyMigrated.slice(0, 50)) console.error(`  migrations-only: ${item}`);
  for (const item of onlySchema.slice(0, 50)) console.error(`  schema-only: ${item}`);
  process.exit(1);
}

console.log(
  `[migration-schema-drift] OK: ${migratedObjects.size} catalogue objects match exactly.`,
);
