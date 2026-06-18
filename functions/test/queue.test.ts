import './helpers';
import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions/v2';
import {
  issueToken,
  callNextToken,
  completeToken,
  noShowToken,
} from '../src/queue';
import {cleanupTenant} from './helpers';

const date = new Date().toISOString().slice(0, 10);

const mockRequest = (data: Record<string, unknown>) => ({
  data,
  auth: {uid: 'u1', token: {} as admin.auth.DecodedIdToken},
  rawRequest: {} as unknown as functions.https.Request,
});

const entriesCol = (tenantId: string) =>
  admin.firestore().collection(`tenants/${tenantId}/tokens/${date}/entries`);

const metaDoc = (tenantId: string) =>
  admin.firestore().doc(`tenants/${tenantId}/tokens/${date}`);

const createEntry = async (
  tenantId: string,
  overrides: Record<string, unknown> = {},
): Promise<{id: string; ref: admin.firestore.DocumentReference}> => {
  const ref = entriesCol(tenantId).doc();
  await ref.set({
    tokenNumber: 1,
    status: 'waiting',
    customerName: 'Test',
    customerPhone: '+919876543210',
    staffId: null,
    serviceId: null,
    bookingId: null,
    tenantId,
    issuedAt: admin.firestore.Timestamp.now(),
    calledAt: null,
    completedAt: null,
    noShowAt: null,
    estimatedWaitMinutes: 0,
    source: 'walk_in',
    ...overrides,
  });
  return {id: ref.id, ref};
};

describe('issueToken', () => {
  const tenantId = 'issue-tenant';

  beforeEach(async () => {
    await cleanupTenant(tenantId);
  });

  afterAll(async () => {
    await cleanupTenant(tenantId);
  });

  test('issueToken increments counter and creates entry', async () => {
    const result = await issueToken.run(mockRequest({
      tenantId,
      customerName: 'Ravi',
      customerPhone: '+919876543210',
      source: 'walk_in',
    }));

    expect(result.entry.tokenNumber).toBe(1);

    const meta = await metaDoc(tenantId).get();
    expect(meta.data()?.nextToken).toBe(2);
  });

  test('issueToken estimates wait based on waiting ahead', async () => {
    await metaDoc(tenantId).set({nextToken: 3});
    await createEntry(tenantId, {tokenNumber: 1, status: 'waiting'});
    await createEntry(tenantId, {tokenNumber: 2, status: 'waiting'});

    const result = await issueToken.run(mockRequest({
      tenantId,
      customerName: 'Ravi',
      customerPhone: '+919876543210',
      source: 'walk_in',
    }));

    expect(result.entry.tokenNumber).toBe(3);
    expect(result.entry.estimatedWaitMinutes).toBe(2 * 15);
  });
});

describe('callNextToken', () => {
  const tenantId = 'call-tenant';

  beforeEach(async () => {
    await cleanupTenant(tenantId);
  });

  afterAll(async () => {
    await cleanupTenant(tenantId);
  });

  test('calls the first waiting entry', async () => {
    const e1 = await createEntry(tenantId, {tokenNumber: 1, status: 'waiting'});
    await createEntry(tenantId, {tokenNumber: 2, status: 'waiting'});

    const result = await callNextToken.run(mockRequest({tenantId}));

    expect(result.id).toBe(e1.id);
    expect(result.entry.status).toBe('serving');
    expect(result.entry.calledAt).toBeInstanceOf(
      admin.firestore.Timestamp,
    );
  });

  test('filters by staffId when provided', async () => {
    await createEntry(tenantId, {
      tokenNumber: 1,
      status: 'waiting',
      staffId: 'staff-a',
    });
    const e2 = await createEntry(tenantId, {
      tokenNumber: 2,
      status: 'waiting',
      staffId: 'staff-b',
    });

    const result = await callNextToken.run(
      mockRequest({tenantId, staffId: 'staff-b'}),
    );

    expect(result.id).toBe(e2.id);
  });

  test('throws when no waiting entries', async () => {
    await expect(
      callNextToken.run(mockRequest({tenantId})),
    ).rejects.toThrow();
  });
});

describe('completeToken', () => {
  const tenantId = 'complete-tenant';

  beforeEach(async () => {
    await cleanupTenant(tenantId);
  });

  afterAll(async () => {
    await cleanupTenant(tenantId);
  });

  test('completes a called entry', async () => {
    const entry = await createEntry(tenantId, {
      tokenNumber: 1,
      status: 'called',
      calledAt: admin.firestore.Timestamp.now(),
    });

    const result = await completeToken.run(
      mockRequest({tenantId, entryId: entry.id}),
    );

    expect(result.entry.status).toBe('completed');
    expect(result.entry.completedAt).toBeInstanceOf(
      admin.firestore.Timestamp,
    );
  });

  test('throws when entry is not called or serving', async () => {
    const entry = await createEntry(tenantId, {
      tokenNumber: 1,
      status: 'waiting',
    });

    await expect(
      completeToken.run(mockRequest({tenantId, entryId: entry.id})),
    ).rejects.toThrow();
  });
});

describe('noShowToken', () => {
  const tenantId = 'noshow-tenant';

  beforeEach(async () => {
    await cleanupTenant(tenantId);
  });

  afterAll(async () => {
    await cleanupTenant(tenantId);
  });

  test('marks a serving entry as no show', async () => {
    const entry = await createEntry(tenantId, {
      tokenNumber: 1,
      status: 'serving',
      calledAt: admin.firestore.Timestamp.now(),
    });

    const result = await noShowToken.run(
      mockRequest({tenantId, entryId: entry.id}),
    );

    expect(result.entry.status).toBe('no_show');
    expect(result.entry.noShowAt).toBeInstanceOf(
      admin.firestore.Timestamp,
    );
  });

  test('throws when entry is not called or serving', async () => {
    const entry = await createEntry(tenantId, {
      tokenNumber: 1,
      status: 'completed',
    });

    await expect(
      noShowToken.run(mockRequest({tenantId, entryId: entry.id})),
    ).rejects.toThrow();
  });
});
