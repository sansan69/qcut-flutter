import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

const callableOptions = {
  cors: ['qcut.co.in', 'localhost'],
  region: 'asia-south1',
};

export const enforcePlanLimits = functions.https.onCall(
  callableOptions,
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError('unauthenticated', 'Login required');
    }
    const { tenantId } = request.data;
    if (!tenantId) {
      throw new functions.https.HttpsError('invalid-argument', 'tenantId required');
    }

    const tenantDoc = await admin.firestore().doc(`tenants/${tenantId}`).get();
    if (!tenantDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Tenant not found');
    }
    const tenant = tenantDoc.data()!;
    const planLevel = tenant.planLevel ?? 0;

    const [barbersSnap, servicesSnap, bookingsSnap] = await Promise.all([
      admin.firestore().collection(`tenants/${tenantId}/barbers`).get(),
      admin.firestore().collection(`tenants/${tenantId}/services`).get(),
      admin.firestore().collection(`tenants/${tenantId}/bookings`).where('status', '==', 'confirmed').get(),
    ]);

    const limits: Record<number, { maxBarbers: number; maxServices: number; appointments: boolean }> = {
      0: { maxBarbers: 2, maxServices: 3, appointments: false },
      1: { maxBarbers: 5, maxServices: 10, appointments: true },
      2: { maxBarbers: 10, maxServices: 20, appointments: true },
    };

    const limit = limits[planLevel] ?? limits[0];

    return {
      maxBarbers: limit.maxBarbers,
      maxServices: limit.maxServices,
      appointments: limit.appointments,
      current: {
        barbers: barbersSnap.size,
        services: servicesSnap.size,
        bookings: bookingsSnap.size,
      },
      barbersOk: barbersSnap.size < limit.maxBarbers,
      servicesOk: servicesSnap.size < limit.maxServices,
    };
  }
);
