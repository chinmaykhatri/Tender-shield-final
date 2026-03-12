import { NextRequest, NextResponse } from 'next/server';
import crypto from 'crypto';

export async function POST(req: NextRequest) {
  try {
    const url = new URL(req.url);
    const amountPaise = parseInt(url.searchParams.get('amount_paise') || '0');

    if (amountPaise <= 0) {
      return NextResponse.json({ detail: 'Invalid amount' }, { status: 400 });
    }

    // Generate ZKP-style commitment (SHA-256 Pedersen simulation)
    const randomness = crypto.randomBytes(32).toString('hex');
    const commitmentInput = `${amountPaise}:${randomness}`;
    const commitmentHash = crypto.createHash('sha256').update(commitmentInput).digest('hex');

    const amountRupees = amountPaise / 100;
    let amountDisplay: string;
    if (amountRupees >= 1_00_00_000) {
      amountDisplay = `₹${(amountRupees / 1_00_00_000).toFixed(2)} Cr`;
    } else if (amountRupees >= 1_00_000) {
      amountDisplay = `₹${(amountRupees / 1_00_000).toFixed(2)} L`;
    } else {
      amountDisplay = `₹${amountRupees.toLocaleString('en-IN', { minimumFractionDigits: 2 })}`;
    }

    return NextResponse.json({
      commitment_hash: commitmentHash,
      zkp_proof: `pedersen_v1_${commitmentHash.slice(0, 16)}`,
      amount_paise: amountPaise,
      amount_display: amountDisplay,
      randomness_hex: randomness,
      warning: 'Save your randomness! You need it to reveal your bid later. If lost, your bid cannot be verified.',
    });
  } catch (err: any) {
    return NextResponse.json({ detail: err.message }, { status: 500 });
  }
}
