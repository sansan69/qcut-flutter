const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { getDoc, setDoc, deleteDoc, doc } = require('firebase/firestore');
const fs = require('fs');
const path = require('path');

const rules = fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8');

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'appointment-32f4a',
    firestore: { rules }
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

test('provider can read own tenant', async () => {
  const provider = testEnv.authenticatedContext('u1', { role: 'provider', tenantId: 't1' });
  await assertSucceeds(getDoc(doc(provider.firestore(), 'tenants/t1')));
});

test('provider cannot read another tenant', async () => {
  const provider = testEnv.authenticatedContext('u1', { role: 'provider', tenantId: 't1' });
  await assertFails(getDoc(doc(provider.firestore(), 'tenants/t2')));
});

test('provider cannot delete token entry', async () => {
  const provider = testEnv.authenticatedContext('u1', { role: 'provider', tenantId: 't1' });
  await assertFails(deleteDoc(doc(provider.firestore(), 'tenants/t1/tokens/2024-01-01/entries/1')));
});

test('provider cannot write to arbitrary tenant subcollection', async () => {
  const provider = testEnv.authenticatedContext('u1', { role: 'provider', tenantId: 't1' });
  await assertFails(setDoc(doc(provider.firestore(), 'tenants/t1/arbitrary/1'), { data: true }));
});
