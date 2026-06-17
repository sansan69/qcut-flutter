import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
import {FieldValue, Timestamp} from 'firebase-admin/firestore';

const region = 'asia-south1';
const callableOptions = {cors: ['qcut.co.in', 'localhost'], region};

/**
 * Returns the current date in ISO format (YYYY-MM-DD).
 *
 * @return {string} The current date.
 */
function today(): string {
  return new Date().toISOString().slice(0, 10);
}

/**
 * Returns a reference to the entries collection for a tenant and date.
 *
 * @param {string} tenantId - The tenant ID.
 * @param {string} date - The date string in YYYY-MM-DD format.
 * @return {admin.firestore.CollectionReference} The entries collection.
 */
function entriesCollection(
  tenantId: string,
  date: string,
): admin.firestore.CollectionReference {
  return admin
    .firestore()
    .collection(`tenants/${tenantId}/tokens/${date}/entries`);
}

/**
 * Returns a reference to the meta document for a tenant and date.
 *
 * @param {string} tenantId - The tenant ID.
 * @param {string} date - The date string in YYYY-MM-DD format.
 * @return {admin.firestore.DocumentReference} The meta document.
 */
function metaRef(
  tenantId: string,
  date: string,
): admin.firestore.DocumentReference {
  return admin.firestore().doc(`tenants/${tenantId}/tokens/${date}`);
}

/**
 * Callable Cloud Function that issues a new token to a customer.
 */
export const issueToken = functions.https.onCall(
  callableOptions,
  async (request) => {
    const {
      tenantId,
      customerName,
      customerPhone,
      staffId,
      serviceId,
      bookingId,
      source,
    } = request.data;
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Login required',
      );
    }

    const date = today();
    const metaDoc = metaRef(tenantId, date);
    const newEntryRef = entriesCollection(tenantId, date).doc();

    const result = await admin.firestore().runTransaction(async (tx) => {
      const meta = await tx.get(metaDoc);
      const nextToken = (meta.exists ?
        meta.data()?.nextToken ?? 1 :
        1) as number;
      tx.set(
        metaDoc,
        {nextToken: nextToken + 1, updatedAt: FieldValue.serverTimestamp()},
        {merge: true},
      );

      const entry = {
        tokenNumber: nextToken,
        status: 'waiting',
        customerName,
        customerPhone,
        staffId: staffId ?? null,
        serviceId: serviceId ?? null,
        bookingId: bookingId ?? null,
        issuedAt: Timestamp.now(),
        calledAt: null,
        completedAt: null,
        noShowAt: null,
        estimatedWaitMinutes: 0,
        source: source ?? 'walk_in',
      };
      tx.set(newEntryRef, entry);
      return {id: newEntryRef.id, entry: {...entry, id: newEntryRef.id}};
    });

    return result;
  },
);
