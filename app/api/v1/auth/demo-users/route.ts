import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({
    demo_users: [
      { email: 'officer@morth.gov.in', name: 'Rajesh Kumar (MoRTH)', role: 'OFFICER', org: 'MinistryOrg' },
      { email: 'medtech@medtechsolutions.com', name: 'Priya Sharma (MedTech)', role: 'BIDDER', org: 'BidderOrg' },
      { email: 'admin@biomedicorp.com', name: 'Shell Corp (BioMedi)', role: 'BIDDER', org: 'BidderOrg' },
      { email: 'auditor@cag.gov.in', name: 'Amit Verma (CAG)', role: 'AUDITOR', org: 'AuditorOrg' },
      { email: 'admin@nic.in', name: 'NIC Administrator', role: 'NIC_ADMIN', org: 'NICOrg' },
    ],
  });
}
