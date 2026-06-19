import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
import {FieldValue, Timestamp} from 'firebase-admin/firestore';

const region = 'asia-south1';
const callableOptions = {cors: ['qcut.co.in', 'localhost'], region};

/**
 * Generates evenly spaced time slots between open and close times.
 *
 * @param {string} open - Opening time in HH:MM format.
 * @param {string} close - Closing time in HH:MM format.
 * @param {number} durationMinutes - The service duration in minutes.
 * @return {string[]} Array of slot start times in HH:MM format.
 */
function generateSlots(
  open: string,
  close: string,
  durationMinutes: number,
): string[] {
  const slots: string[] = [];
  let [h, m] = open.split(':').map(Number);
  const [endH, endM] = close.split(':').map(Number);
  const end = endH * 60 + endM;
  while (h * 60 + m + durationMinutes <= end) {
    slots.push(`${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`);
    m += durationMinutes;
    if (m >= 60) {
      h += Math.floor(m / 60);
      m = m % 60;
    }
  }
  return slots;
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
 * Callable Cloud Function that returns available appointment slots for a
 * tenant on a given date, accounting for service duration and existing
 * confirmed/completed bookings.
 */
export const getAvailableSlots = functions.https.onCall(
  callableOptions,
  async (request) => {
    const {tenantId, serviceId, date, staffId} = request.data;

    const tenantDoc = await admin
      .firestore()
      .doc(`tenants/${tenantId}`)
      .get();
    if (!tenantDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Tenant not found');
    }
    const tenant = tenantDoc.data()!;
    if (tenant.bookingMode === 'token') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Appointments not enabled',
      );
    }

    if (!tenant.openTime || !tenant.closeTime) {
      return {slots: []};
    }

    const serviceDoc = await admin
      .firestore()
      .doc(`tenants/${tenantId}/services/${serviceId}`)
      .get();
    if (!serviceDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Service not found');
    }
    const duration = serviceDoc.data()?.durationMinutes ?? 30;

    const allSlots = generateSlots(tenant.openTime, tenant.closeTime, duration);

    let bookingsQuery: admin.firestore.Query = admin
      .firestore()
      .collection(`tenants/${tenantId}/bookings`)
      .where('date', '==', date)
      .where('status', 'in', ['confirmed', 'completed']);
    if (staffId) {
      bookingsQuery = bookingsQuery.where('staffId', '==', staffId);
    }
    const bookings = await bookingsQuery.get();
    const bookedSlots = new Set(bookings.docs.map((d) => d.data().timeSlot));

    return {slots: allSlots.filter((s) => !bookedSlots.has(s))};
  },
);

/**
 * Callable Cloud Function that creates a new booking with status confirmed.
 * Validates the tenant exists, appointments are enabled, and the requested
 * slot is not already booked.
 */
export const createBooking = functions.https.onCall(
  callableOptions,
  async (request) => {
    const {
      tenantId,
      customerName,
      customerPhone,
      serviceId,
      date,
      timeSlot,
      staffId,
      serviceType: requestServiceType,
    } = request.data;

    const tenantDoc = await admin
      .firestore()
      .doc(`tenants/${tenantId}`)
      .get();
    if (!tenantDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Tenant not found');
    }
    if (tenantDoc.data()!.bookingMode === 'token') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Appointments not enabled',
      );
    }

    let barberName: string | null = null;
    if (staffId) {
      const barberDoc = await admin
        .firestore()
        .doc(`tenants/${tenantId}/barbers/${staffId}`)
        .get();
      if (barberDoc.exists) {
        barberName = barberDoc.data()!.name ?? null;
      }
    }

    let serviceType: string | null = requestServiceType ?? null;
    if (!serviceType) {
      const svcDoc = await admin
        .firestore()
        .doc(`tenants/${tenantId}/services/${serviceId}`)
        .get();
      if (svcDoc.exists) {
        serviceType = svcDoc.data()!.name ?? null;
      }
    }

    const bookingCode = 'QCUT-' + Math.random().toString(36).substring(2, 8).toUpperCase();

    let existingQuery: admin.firestore.Query = admin
      .firestore()
      .collection(`tenants/${tenantId}/bookings`)
      .where('date', '==', date)
      .where('timeSlot', '==', timeSlot)
      .where('status', 'in', ['confirmed', 'completed']);
    if (staffId) {
      existingQuery = existingQuery.where('staffId', '==', staffId);
    } else {
      existingQuery = existingQuery.where('staffId', '==', null);
    }
    const existing = await existingQuery.limit(1).get();
    if (!existing.empty) {
      throw new functions.https.HttpsError(
        'already-exists',
        'Slot unavailable',
      );
    }

    const ref = admin
      .firestore()
      .collection(`tenants/${tenantId}/bookings`)
      .doc();
    const entry = {
      customerName,
      customerPhone,
      serviceId,
      staffId: staffId ?? null,
      barberName,
      serviceType,
      bookingCode,
      date,
      timeSlot,
      status: 'confirmed',
      tokenId: null,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    };
    await ref.set(entry);
    return {id: ref.id, entry: {...entry, id: ref.id}};
  },
);

/**
 * Callable Cloud Function that cancels an existing booking by setting its
 * status to cancelled. Requires authentication.
 */
export const cancelBooking = functions.https.onCall(
  callableOptions,
  async (request) => {
    const {tenantId, bookingId} = request.data;
    if (!request.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Login required',
      );
    }

    const ref = admin
      .firestore()
      .doc(`tenants/${tenantId}/bookings/${bookingId}`);
    const doc = await ref.get();
    if (!doc.exists) {
      throw new functions.https.HttpsError('not-found', 'Booking not found');
    }

    await ref.update({status: 'cancelled', updatedAt: Timestamp.now()});
    const updated = await ref.get();
    const data = updated.data()!;
    const entry = {...data, id: updated.id, status: 'cancelled'};
    return {id: updated.id, entry};
  },
);

/**
 * Callable Cloud Function that converts a confirmed booking into a live token.
 * Uses a Firestore transaction to atomically increment the daily token counter,
 * create a token entry, and link it back to the booking. Requires
 * authentication.
 */
export const convertBookingToToken = functions.https.onCall(
  callableOptions,
  async (request) => {
    const {tenantId, bookingId} = request.data;
    if (!request.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Login required',
      );
    }

    const bookingRef = admin
      .firestore()
      .doc(`tenants/${tenantId}/bookings/${bookingId}`);
    const booking = await bookingRef.get();
    if (!booking.exists) {
      throw new functions.https.HttpsError('not-found', 'Booking not found');
    }
    const b = booking.data()!;
    if (b.status !== 'confirmed') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Booking not confirmed',
      );
    }

    const date = b.date;
    const metaDoc = metaRef(tenantId, date);
    const newEntryRef = entriesCollection(tenantId, date).doc();

    const result = await admin.firestore().runTransaction(async (tx) => {
      const meta = await tx.get(metaDoc);
      const nextToken = (
        meta.exists ? meta.data()?.nextToken ?? 1 : 1
      ) as number;
      tx.set(
        metaDoc,
        {nextToken: nextToken + 1, updatedAt: FieldValue.serverTimestamp()},
        {merge: true},
      );

      const entry = {
        tokenNumber: nextToken,
        status: 'waiting',
        customerName: b.customerName,
        customerPhone: b.customerPhone,
        staffId: b.staffId ?? null,
        serviceId: b.serviceId,
        bookingId,
        tenantId,
        issuedAt: Timestamp.now(),
        calledAt: null,
        completedAt: null,
        noShowAt: null,
        estimatedWaitMinutes: 0,
        source: 'app',
      };
      tx.set(newEntryRef, entry);
      tx.update(bookingRef, {
        tokenId: newEntryRef.id,
        status: 'completed',
        updatedAt: Timestamp.now(),
      });
      return {id: newEntryRef.id, entry: {...entry, id: newEntryRef.id}};
    });

    return result;
  },
);
