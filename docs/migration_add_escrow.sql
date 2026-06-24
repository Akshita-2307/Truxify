-- Migration: Add Escrow Smart Contract fields to orders table
-- Tracks escrow deposit, release, and refund transaction hashes and status.
--
-- Prerequisites:
--   1. Escrow.sol deployed to Polygon and ESCROW_CONTRACT_ADDRESS set in .env
--   2. RELAYER_WALLET_PRIVATE_KEY set in .env with authorized relayer role
--
-- Run this in Supabase SQL Editor after deployment.

-- Escrow booking identifier (e.g. "escrow:#FF202605211234")
ALTER TABLE orders ADD COLUMN IF NOT EXISTS escrow_booking_id TEXT;

-- Escrow status:
-- null | 'funding' | 'funded' | 'release_pending' | 'release_failed' |
-- 'released' | 'refunded'
ALTER TABLE orders ADD COLUMN IF NOT EXISTS escrow_status TEXT;

-- Deposit transaction hash from Escrow.sol.deposit()
ALTER TABLE orders ADD COLUMN IF NOT EXISTS deposit_tx_hash TEXT;

-- Release transaction hash from Escrow.sol.releaseFunds()
ALTER TABLE orders ADD COLUMN IF NOT EXISTS release_tx_hash TEXT;

-- Refund transaction hash from Escrow.sol.refundFunds()
ALTER TABLE orders ADD COLUMN IF NOT EXISTS refund_tx_hash TEXT;

-- Timestamps for each escrow lifecycle event
ALTER TABLE orders ADD COLUMN IF NOT EXISTS escrow_deposited_at TIMESTAMPTZ;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS escrow_released_at TIMESTAMPTZ;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS escrow_refunded_at TIMESTAMPTZ;

-- Durable release retry and reconciliation metadata
ALTER TABLE orders ADD COLUMN IF NOT EXISTS escrow_release_error TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS escrow_release_attempts INTEGER NOT NULL DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS escrow_release_last_attempt_at TIMESTAMPTZ;
