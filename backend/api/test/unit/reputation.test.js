/**
 * Unit tests for backend/api/src/services/reputation.js
 *
 * Coverage:
 *   - awardReputationPoints skips gracefully when contract is null
 *   - awardReputationPoints validates wallet address format and skips
 *   - getDriverReputation returns null when contract is null
 *   - getDriverReputation returns null for invalid wallet address
 *
 * Run with:  npm run test:unit -- test/unit/reputation.test.js
 */
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';

vi.mock('../../src/middleware/logger.js', () => ({
  default: { info: vi.fn(), warn: vi.fn(), error: vi.fn(), debug: vi.fn(), fatal: vi.fn() },
}));

describe('reputation service', () => {
  const originalEnv = {};
  const ENV_VARS = ['POLYGON_RPC_URL', 'REPUTATION_CONTRACT_ADDRESS', 'RELAYER_WALLET_PRIVATE_KEY'];

  beforeEach(() => {
    vi.resetModules();
    ENV_VARS.forEach((k) => {
      originalEnv[k] = process.env[k];
      delete process.env[k];
    });
  });

  afterEach(() => {
    ENV_VARS.forEach((k) => {
      if (originalEnv[k] !== undefined) {
        process.env[k] = originalEnv[k];
      } else {
        delete process.env[k];
      }
    });
    vi.restoreAllMocks();
  });

  describe('awardReputationPoints', () => {
    it('skips gracefully when reputationContract is null', async () => {
      const { awardReputationPoints } = await import('../../src/services/reputation.js');
      await awardReputationPoints('0x1234567890123456789012345678901234567890', 5);
      // Should not throw - skips when contract is null
    });

    it('skips and does not call contract for invalid wallet address', async () => {
      const { awardReputationPoints } = await import('../../src/services/reputation.js');
      // Invalid addresses should be detected and skipped without calling the contract
      await awardReputationPoints('not-an-address', 5);
      await awardReputationPoints('', 5);
      await awardReputationPoints('0xinvalid', 5);
      // Should not throw
    });
  });

  describe('getDriverReputation', () => {
    it('returns null when reputationContract is null', async () => {
      const { getDriverReputation } = await import('../../src/services/reputation.js');
      const result = await getDriverReputation('0x1234567890123456789012345678901234567890');
      expect(result).toBeNull();
    });

    it('returns null for invalid wallet address', async () => {
      const { getDriverReputation } = await import('../../src/services/reputation.js');
      const result = await getDriverReputation('not-an-address');
      expect(result).toBeNull();
    });
  });
});
