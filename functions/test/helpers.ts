import * as admin from 'firebase-admin';
import * as net from 'net';

const projectId = process.env.GCLOUD_PROJECT || 'qcut-test';

if (!process.env.FIRESTORE_EMULATOR_HOST) {
  process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';
}

const [emulatorHost, emulatorPort] =
  process.env.FIRESTORE_EMULATOR_HOST.split(':');

/**
 * Checks whether the Firestore emulator is reachable.
 *
 * @return {Promise<boolean>} True if the emulator is reachable.
 */
function isEmulatorReachable(): Promise<boolean> {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    socket.setTimeout(1000);
    socket.once('connect', () => {
      socket.destroy();
      resolve(true);
    });
    socket.once('timeout', () => {
      socket.destroy();
      resolve(false);
    });
    socket.once('error', () => {
      resolve(false);
    });
    socket.connect(Number(emulatorPort), emulatorHost);
  });
}

if (admin.apps.length === 0) {
  admin.initializeApp({projectId});
}

const firestore = admin.firestore();

/**
 * Minimal test environment metadata.
 */
export interface TestEnv {
  projectId: string;
}

/**
 * Returns the shared test environment.
 *
 * @return {TestEnv} The test environment.
 */
export function getTestEnv(): TestEnv {
  return {projectId};
}

/**
 * Ensures the Firestore emulator is available before running tests.
 */
export async function requireEmulator(): Promise<void> {
  const reachable = await isEmulatorReachable();
  if (!reachable) {
    throw new Error(
      `Firestore emulator is not reachable at ${process.env.FIRESTORE_EMULATOR_HOST}. ` +
        'Start it with: firebase emulators:start --only firestore',
    );
  }
}

/**
 * Recursively deletes a Firestore document and its subcollections.
 *
 * @param {admin.firestore.DocumentReference} doc - The document to delete.
 * @return {Promise<void>}
 */
async function deleteDocument(
  doc: admin.firestore.DocumentReference,
): Promise<void> {
  const collections = await doc.listCollections();
  await Promise.all(
    collections.map(async (collection) => {
      const snapshots = await collection.get();
      await Promise.all(snapshots.docs.map((d) => deleteDocument(d.ref)));
    }),
  );
  await doc.delete();
}

/**
 * Removes all data under a tenant for test isolation.
 *
 * @param {string} tenantId - The tenant ID to clean up.
 * @return {Promise<void>}
 */
export async function cleanupTenant(tenantId: string): Promise<void> {
  await requireEmulator();
  const tenantDoc = firestore.doc(`tenants/${tenantId}`);
  await deleteDocument(tenantDoc);
}
