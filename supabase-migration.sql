-- ============================================================
-- TenderShield — Supabase Database Migration
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- 1. Profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT NOT NULL DEFAULT '',
  role TEXT NOT NULL DEFAULT 'BIDDER' CHECK (role IN ('OFFICER', 'BIDDER', 'AUDITOR', 'NIC_ADMIN')),
  org TEXT NOT NULL DEFAULT 'BidderOrg',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public profiles are viewable by everyone" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Service role can insert profiles" ON profiles
  FOR INSERT WITH CHECK (true);

-- 2. Tenders table
CREATE TABLE IF NOT EXISTS tenders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tender_id TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  ministry_code TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'WORKS' CHECK (category IN ('WORKS', 'GOODS', 'SERVICES', 'CONSULTANCY')),
  estimated_value_paise BIGINT NOT NULL DEFAULT 0,
  procurement_method TEXT DEFAULT 'OPEN_TENDER',
  status TEXT NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'PUBLISHED', 'BIDDING_OPEN', 'UNDER_EVALUATION', 'AWARDED', 'FROZEN_BY_AI', 'CANCELLED')),
  created_by UUID REFERENCES profiles(id),
  bid_start_date TIMESTAMPTZ,
  bid_end_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE tenders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tenders are viewable by everyone" ON tenders
  FOR SELECT USING (true);

CREATE POLICY "Officers can create tenders" ON tenders
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Officers can update tenders" ON tenders
  FOR UPDATE USING (true);

-- 3. Bids table
CREATE TABLE IF NOT EXISTS bids (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bid_id TEXT UNIQUE NOT NULL,
  tender_id TEXT NOT NULL REFERENCES tenders(tender_id),
  bidder_id UUID REFERENCES profiles(id),
  bidder_did TEXT DEFAULT '',
  commitment_hash TEXT NOT NULL,
  zkp_proof TEXT DEFAULT '',
  status TEXT NOT NULL DEFAULT 'COMMITTED' CHECK (status IN ('COMMITTED', 'REVEALED', 'REJECTED', 'VERIFIED')),
  revealed_amount_paise BIGINT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE bids ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Bids are viewable by authenticated users" ON bids
  FOR SELECT USING (true);

CREATE POLICY "Bidders can insert bids" ON bids
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Bids can be updated" ON bids
  FOR UPDATE USING (true);

-- 4. Audit Events table
CREATE TABLE IF NOT EXISTS audit_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id TEXT UNIQUE NOT NULL,
  event_type TEXT NOT NULL,
  topic TEXT NOT NULL DEFAULT 'tender-events',
  timestamp_ist TEXT DEFAULT '',
  data JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE audit_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Audit events are viewable by everyone" ON audit_events
  FOR SELECT USING (true);

CREATE POLICY "Audit events can be inserted" ON audit_events
  FOR INSERT WITH CHECK (true);

-- ============================================================
-- SEED DATA
-- ============================================================

-- Seed Tenders
INSERT INTO tenders (tender_id, title, description, ministry_code, category, estimated_value_paise, procurement_method, status, bid_start_date, bid_end_date)
VALUES 
  ('TDR-MoRTH-2025-000001', 'National Highway 8-Lane Expansion — Delhi-Jaipur Corridor', 'Construction of 8-lane access-controlled expressway from Delhi to Jaipur (280 km). Includes toll plazas, service roads, and smart highway features.', 'MoRTH', 'WORKS', 4500000000000, 'OPEN_TENDER', 'BIDDING_OPEN', NOW() - INTERVAL '5 days', NOW() + INTERVAL '25 days'),
  ('TDR-MoE-2025-000001', 'AI-Powered Smart Classroom Equipment — 500 KVS Schools', 'Supply and installation of interactive smart boards, AI tutoring systems, and IoT sensors across 500 Kendriya Vidyalaya schools.', 'MoE', 'GOODS', 850000000000, 'OPEN_TENDER', 'BIDDING_OPEN', NOW() - INTERVAL '3 days', NOW() + INTERVAL '27 days'),
  ('TDR-MoH-2025-000001', 'Telemedicine Infrastructure — 200 District Hospitals', 'Design, supply, and commissioning of telemedicine units with video conferencing, remote diagnostics, and EHR integration for 200 district hospitals.', 'MoH', 'SERVICES', 1200000000000, 'OPEN_TENDER', 'UNDER_EVALUATION', NOW() - INTERVAL '30 days', NOW() - INTERVAL '2 days')
ON CONFLICT (tender_id) DO NOTHING;

-- Seed Audit Events
INSERT INTO audit_events (event_id, event_type, topic, timestamp_ist, data)
VALUES
  ('EVT-001', 'TENDER_CREATED', 'tender-events', '2025-03-12T10:30:15+05:30', '{"tender_id": "TDR-MoRTH-2025-000001", "ministry": "MoRTH", "value_cr": 450}'::jsonb),
  ('EVT-002', 'TENDER_PUBLISHED', 'tender-events', '2025-03-12T10:35:22+05:30', '{"tender_id": "TDR-MoRTH-2025-000001", "channel": "TenderChannel"}'::jsonb),
  ('EVT-003', 'TENDER_CREATED', 'tender-events', '2025-03-12T11:00:00+05:30', '{"tender_id": "TDR-MoE-2025-000001", "ministry": "MoE", "value_cr": 85}'::jsonb),
  ('EVT-004', 'TENDER_PUBLISHED', 'tender-events', '2025-03-12T11:05:00+05:30', '{"tender_id": "TDR-MoE-2025-000001", "channel": "TenderChannel"}'::jsonb),
  ('EVT-005', 'TENDER_CREATED', 'tender-events', '2025-03-12T12:00:00+05:30', '{"tender_id": "TDR-MoH-2025-000001", "ministry": "MoH", "value_cr": 120}'::jsonb),
  ('EVT-006', 'BID_COMMITTED', 'bid-events', '2025-03-12T14:30:45+05:30', '{"bid_id": "BID-001", "tender_id": "TDR-MoH-2025-000001", "phase": "ZKP_COMMIT"}'::jsonb),
  ('EVT-007', 'BID_COMMITTED', 'bid-events', '2025-03-12T14:31:10+05:30', '{"bid_id": "BID-002", "tender_id": "TDR-MoH-2025-000001", "phase": "ZKP_COMMIT"}'::jsonb),
  ('EVT-008', 'AI_ALERT_GENERATED', 'ai-alerts', '2025-03-12T14:35:00+05:30', '{"alert_id": "ALERT-001", "tender_id": "TDR-MoH-2025-000001", "risk_score": 62, "type": "BID_RIGGING"}'::jsonb),
  ('EVT-009', 'TENDER_FROZEN', 'tender-events', '2025-03-12T15:00:00+05:30', '{"tender_id": "TDR-MoH-2025-000001", "reason": "AI fraud detection — bid rigging suspected"}'::jsonb),
  ('EVT-010', 'ZKP_VERIFICATION_PASSED', 'audit-events', '2025-03-12T15:05:33+05:30', '{"bid_id": "BID-001", "verification": "PEDERSEN_COMMITMENT_VALID"}'::jsonb)
ON CONFLICT (event_id) DO NOTHING;

-- Done! ✅
