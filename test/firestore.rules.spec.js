const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { getDoc, doc } = require('firebase/firestore');
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
