import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
import {FieldValue, Timestamp} from 'firebase-admin/firestore';

const region = 'asia-south1';
const callableOptions = {cors: ['qcut.co.in', 'localhost'], region};
const DEFAULT_SERVICE_MINUTES = 15;

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
 * Computes the average service duration in minutes from the last 20
 * completed tokens for a tenant.
 *
 * @param {string} tenantId - The tenant ID.
 * @param {admin.firestore.Transaction} tx - The current transaction.
 * @return {Promise<number>} Average service duration in minutes.
 */
async function getAverageServiceDuration(
  tenantId: string,
  tx: admin.firestore.Transaction,
): Promise<number> {
  const query = admin
    .firestore()
    .collectionGroup('entries')
    .where('tenantId', '==', tenantId)
    .where('status', '==', 'completed')
    .orderBy('completedAt', 'desc')
    .limit(20);

  const snapshot = await tx.get(query);
  if (snapshot.empty) {
    return DEFAULT_SERVICE_MINUTES;
  }

  let totalMinutes = 0;
  let count = 0;
  snapshot.forEach((doc) => {
    const data = doc.data();
    const calledAt = data.calledAt as Timestamp | undefined;
    const completedAt = data.completedAt as Timestamp | undefined;
    if (calledAt && completedAt) {
      const durationMs = completedAt.toMillis() - calledAt.toMillis();
      totalMinutes += durationMs / 60000;
      count++;
    }
  });

  return count > 0 ? totalMinutes / count : DEFAULT_SERVICE_MINUTES;
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

      const waitingAheadQuery = entriesCollection(tenantId, date)
        .where('status', '==', 'waiting')
        .where('tokenNumber', '<', nextToken);
      const waitingAheadSnapshot = await tx.get(waitingAheadQuery);
      const waitingAhead = waitingAheadSnapshot.size;

      const averageServiceMinutes = await getAverageServiceDuration(
        tenantId,
        tx,
      );
      const estimatedWaitMinutes = waitingAhead * averageServiceMinutes;

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
        tenantId,
        issuedAt: Timestamp.now(),
        calledAt: null,
        completedAt: null,
        noShowAt: null,
        estimatedWaitMinutes,
        source: source ?? 'walk_in',
      };
      tx.set(newEntryRef, entry);
      return {id: newEntryRef.id, entry: {...entry, id: newEntryRef.id}};
    });

    return result;
  },
);

/**
 * Callable Cloud Function that calls the next waiting token.
 */
export const callNextToken = functions.https.onCall(
  callableOptions,
  async (request) => {
    const {tenantId, staffId} = request.data;
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Login required',
      );
    }

    const date = today();
    const entriesCol = entriesCollection(tenantId, date);

    const result = await admin.firestore().runTransaction(async (tx) => {
      let query = entriesCol
        .where('status', '==', 'waiting')
        .orderBy('tokenNumber', 'asc')
        .limit(1);
      if (staffId) {
        query = query.where('staffId', '==', staffId);
      }

      const snapshot = await tx.get(query);
      if (snapshot.empty) {
        throw new functions.https.HttpsError(
          'not-found',
          'No waiting tokens',
        );
      }

      const doc = snapshot.docs[0];
      const entryRef = doc.ref;
      const calledAt = Timestamp.now();
      tx.update(entryRef, {status: 'called', calledAt});

      const entry = {...doc.data(), status: 'called', calledAt};
      return {id: doc.id, entry};
    });

    return result;
  },
);

/**
 * Callable Cloud Function that marks a called/serving token as completed.
 */
export const completeToken = functions.https.onCall(
  callableOptions,
  async (request) => {
    const {tenantId, entryId} = request.data;
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Login required',
      );
    }

    const date = today();
    const entryRef = entriesCollection(tenantId, date).doc(entryId);

    const result = await admin.firestore().runTransaction(async (tx) => {
      const doc = await tx.get(entryRef);
      if (!doc.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'Token not found',
        );
      }

      const data = doc.data()!;
      if (data.status !== 'called' && data.status !== 'serving') {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Token must be called or serving',
        );
      }

      const completedAt = Timestamp.now();
      tx.update(entryRef, {status: 'completed', completedAt});

      const entry = {...data, status: 'completed', completedAt};
      return {id: doc.id, entry};
    });

    return result;
  },
);

/**
 * Callable Cloud Function that marks a called/serving token as no-show.
 */
export const noShowToken = functions.https.onCall(
  callableOptions,
  async (request) => {
    const {tenantId, entryId} = request.data;
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Login required',
      );
    }

    const date = today();
    const entryRef = entriesCollection(tenantId, date).doc(entryId);

    const result = await admin.firestore().runTransaction(async (tx) => {
      const doc = await tx.get(entryRef);
      if (!doc.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'Token not found',
        );
      }

      const data = doc.data()!;
      if (data.status !== 'called' && data.status !== 'serving') {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Token must be called or serving',
        );
      }

      const noShowAt = Timestamp.now();
      tx.update(entryRef, {status: 'no_show', noShowAt});

      const entry = {...data, status: 'no_show', noShowAt};
      return {id: doc.id, entry};
    });

    return result;
  },
);
