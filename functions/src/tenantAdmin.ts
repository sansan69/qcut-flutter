import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

const callableOptions = {
  cors: ['qcut.co.in', 'localhost'],
  region: 'asia-south1',
};

/**
 * Called by platform admin to create a tenant + auth account in one shot.
 * Generates a random password, creates the Firebase Auth user, writes the
 * tenant doc, sets custom claims, and returns the credentials.
 */
export const createTenantAccount = functions.https.onCall(
  callableOptions,
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError('unauthenticated', 'Login required');
    }

    // Only platform_admin can call this
    const caller = await admin.auth().getUser(uid);
    if (caller.customClaims?.role !== 'platform_admin') {
      throw new functions.https.HttpsError('permission-denied', 'Only platform admin can create tenants');
    }

    const { name, ownerEmail, ownerName, phone, ownerPhone, address, businessType, bookingMode, planLevel, openTime, closeTime, password } = request.data;

    if (!name || !ownerEmail || !password) {
      throw new functions.https.HttpsError('invalid-argument', 'name, ownerEmail, and password are required');
    }

    // 1. Create Firebase Auth user
    let authUser;
    try {
      authUser = await admin.auth().createUser({
        email: ownerEmail,
        password: password,
        displayName: ownerName || name,
        emailVerified: false,
      });
    } catch (e: any) {
      if (e.code === 'auth/email-already-exists') {
        authUser = await admin.auth().getUserByEmail(ownerEmail);
      } else {
        throw new functions.https.HttpsError('internal', `Failed to create auth account: ${e.message}`);
      }
    }

    // 2. Create tenant doc
    const slug = name
      .toLowerCase()
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .replace(/^-|-$/g, '');

    const tenantRef = await admin.firestore().collection('tenants').add({
      name,
      ownerEmail,
      ownerName: ownerName || '',
      phone: phone || '',
      ownerPhone: ownerPhone || '',
      address: address || '',
      businessType: businessType || 'salon',
      bookingMode: bookingMode || 'token',
      planLevel: planLevel ?? 0,
      openTime: openTime || '09:00',
      closeTime: closeTime || '21:00',
      slug,
      status: 'active',
      createdBy: uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      configuredAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 3. Write user profile doc with role
    await admin.firestore().doc(`users/${authUser.uid}`).set({
      email: ownerEmail,
      role: 'provider',
      tenantId: tenantRef.id,
      displayName: ownerName || name,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 4. Set custom claims
    await admin.auth().setCustomUserClaims(authUser.uid, {
      role: 'provider',
      tenantId: tenantRef.id,
    });

    return {
      success: true,
      tenantId: tenantRef.id,
      email: ownerEmail,
      password: password,
      slug,
    };
  }
);
