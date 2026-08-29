import * as dotenv from 'dotenv';
import { hash } from 'bcryptjs';

// Load env vars before importing db
dotenv.config({ path: '.env.local' });

async function seedAdmin() {
  try {
    const { db } = await import('../lib/db');
    const { users } = await import('../lib/db/schema');
    const { eq } = await import('drizzle-orm');

    const adminEmail = process.env.ADMIN_EMAIL || 'admin@example.com';
    const adminPassword = process.env.ADMIN_PASSWORD || 'admin123';
    const passwordWasProvided = Boolean(process.env.ADMIN_PASSWORD);

    const [existingAdmin] = await db
      .select({ id: users.id })
      .from(users)
      .where(eq(users.email, adminEmail))
      .limit(1);

    if (existingAdmin) {
      console.log('✅ Admin user already exists; leaving it unchanged.');
    } else {
      const hashedPassword = await hash(adminPassword, 10);
      await db.insert(users).values({
        name: 'Admin User',
        email: adminEmail,
        password: hashedPassword,
        role: 'admin',
        active: true,
      });
      console.log('✅ Admin user created successfully!');
    }

    console.log('Email:', adminEmail);
    if (!passwordWasProvided && !existingAdmin) {
      console.log('Password:', adminPassword, '(default; change it immediately)');
    }
  } catch (error) {
    console.error('❌ Error creating admin user:', error);
    process.exit(1);
  }
  process.exit(0);
}

seedAdmin();
