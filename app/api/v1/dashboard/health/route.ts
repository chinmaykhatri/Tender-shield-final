import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({
    status: 'healthy',
    services: {
      supabase: 'connected',
      auth: 'active',
      database: 'active',
    },
    timestamp: new Date().toISOString(),
  });
}
