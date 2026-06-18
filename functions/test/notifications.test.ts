import * as admin from 'firebase-admin';
import {getTokensToNotify} from '../src/notifications';
import {cleanupTenant, cleanupUsers} from './helpers';

const date = new Date().toISOString().slice(0, 10);

const entriesCol = (tenantId: string) =>
  admin
    .firestore()
    .collection(`tenants/${tenantId}/tokens/${date}/entries`);

const usersCol = () => admin.firestore().collection('users');

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

const createUser = async (
  phone: string,
  fcmTokens: string[] = [],
): Promise<admin.firestore.DocumentReference> => {
  const ref = usersCol().doc();
  await ref.set({phone, fcmTokens});
  return ref;
};

const deleteUserDocs = async (
  refs: admin.firestore.DocumentReference[],
): Promise<void> => {
  await Promise.all(refs.map((r) => r.delete()));
};

describe('getTokensToNotify', () => {
  const tenantId = 'notify-tenant';
  let userRefs: admin.firestore.DocumentReference[] = [];

  beforeEach(async () => {
    await cleanupTenant(tenantId);
    await cleanupUsers();
    userRefs = [];
  });

  afterAll(async () => {
    await cleanupTenant(tenantId);
    await deleteUserDocs(userRefs);
  });

  test('returns tokens for entries within 2 positions of current', async () => {
    const phone5 = '+919999999995';
    const phone6 = '+919999999996';
    const phone7 = '+919999999997';
    const phone8 = '+919999999998';

    userRefs.push(await createUser(phone5, ['token-5']));
    userRefs.push(await createUser(phone6, ['token-6']));
    userRefs.push(await createUser(phone7, ['token-7']));
    userRefs.push(await createUser(phone8, ['token-8']));

    await createEntry(tenantId, {tokenNumber: 5, customerPhone: phone5});
    await createEntry(tenantId, {tokenNumber: 6, customerPhone: phone6});
    await createEntry(tenantId, {tokenNumber: 7, customerPhone: phone7});
    await createEntry(tenantId, {tokenNumber: 8, customerPhone: phone8});

    const tokens = await getTokensToNotify(tenantId, date, 5);

    expect(tokens).toContain('token-5');
    expect(tokens).toContain('token-6');
    expect(tokens).toContain('token-7');
    expect(tokens).not.toContain('token-8');
  });

  test('returns empty when no entries in range', async () => {
    await createEntry(tenantId, {
      tokenNumber: 20,
      customerPhone: '+919999999920',
    });

    const tokens = await getTokensToNotify(tenantId, date, 5);
    expect(tokens).toEqual([]);
  });

  test('includes called status entries', async () => {
    const phone5 = '+919999999995';
    userRefs.push(await createUser(phone5, ['token-5']));

    await createEntry(tenantId, {
      tokenNumber: 5,
      status: 'called',
      calledAt: admin.firestore.Timestamp.now(),
      customerPhone: phone5,
    });

    const tokens = await getTokensToNotify(tenantId, date, 5);
    expect(tokens).toContain('token-5');
  });

  test('skips entries with no customerPhone', async () => {
    await createEntry(tenantId, {tokenNumber: 5, customerPhone: null});

    const tokens = await getTokensToNotify(tenantId, date, 5);
    expect(tokens).toEqual([]);
  });
});
