/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  env: {
    NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://bwbwxpkjrlzcbvtnbdpr.supabase.co',
    NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3Ynd4cGtqcmx6Y2J2dG5iZHByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzMTUyMDUsImV4cCI6MjA4ODg5MTIwNX0.IBUhTIrg4leGbDMOa0R02qp9CG8PNBQGGQ4l4Ntk-9E',
  },
};

module.exports = nextConfig;
