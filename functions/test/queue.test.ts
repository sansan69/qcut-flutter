import './helpers';
import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions/v2';
import {issueToken} from '../src/queue';

const date = new Date().toISOString().slice(0, 10);

describe('issueToken', () => {
  test('issueToken increments counter and creates entry', async () => {
    const result = await issueToken.run({
      data: {
        tenantId: 't1',
        customerName: 'Ravi',
        customerPhone: '+919876543210',
        source: 'walk_in',
      },
      auth: {uid: 'u1', token: {} as admin.auth.DecodedIdToken},
      rawRequest: {} as unknown as functions.https.Request,
    });

    expect(result.entry.tokenNumber).toBe(1);

    const meta = await admin
      .firestore()
      .doc(`tenants/t1/tokens/${date}`)
      .get();
    expect(meta.data()?.nextToken).toBe(2);
  });
});
