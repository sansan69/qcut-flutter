import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

admin.initializeApp();

const callableOptions = {
  cors: ['qcut.co.in', 'localhost'],
  region: 'asia-south1',
};

export const helloWorld = functions.https.onCall(callableOptions, () => {
  return {message: 'Hello from QCUT'};
});

export const refreshCustomClaims = functions.https.onCall(
  callableOptions,
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Login required',
      );
    }

    const userDoc = await admin.firestore().doc(`users/${uid}`).get();
    const data = userDoc.data() ?? {};
    const role = data['role'] ?? 'customer';
    const tenantId = data['tenantId'] ?? null;

    await admin.auth().setCustomUserClaims(uid, {role, tenantId});
    return {success: true};
  },
);

export {issueToken} from './queue';
