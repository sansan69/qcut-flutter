import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions/v2';
import {
  getAvailableSlots,
  createBooking,
  cancelBooking,
  convertBookingToToken,
} from '../src/booking';
import {cleanupTenant} from './helpers';

const date = new Date().toISOString().slice(0, 10);

const mockRequest = (data: Record<string, unknown>, auth = true) => ({
  data,
  auth: auth ? {uid: 'u1', token: {} as admin.auth.DecodedIdToken} : undefined,
  rawRequest: {} as unknown as functions.https.Request,
});

const mockUnauthRequest = (data: Record<string, unknown>) => ({
  data,
  auth: undefined,
  rawRequest: {} as unknown as functions.https.Request,
});

const tenantDoc = (tenantId: string) =>
  admin.firestore().doc(`tenants/${tenantId}`);

const serviceDoc = (tenantId: string, serviceId: string) =>
  admin.firestore().doc(`tenants/${tenantId}/services/${serviceId}`);

const bookingsCol = (tenantId: string) =>
  admin.firestore().collection(`tenants/${tenantId}/bookings`);

const entriesCol = (tenantId: string) =>
  admin.firestore().collection(`tenants/${tenantId}/tokens/${date}/entries`);

const metaDoc = (tenantId: string) =>
  admin.firestore().doc(`tenants/${tenantId}/tokens/${date}`);

const setupTenant = async (
  tenantId: string,
  overrides: Record<string, unknown> = {},
): Promise<void> => {
  await tenantDoc(tenantId).set({
    name: 'Test Tenant',
    bookingMode: 'appointment',
    openTime: '09:00',
    closeTime: '17:00',
    ...overrides,
  });
};

const setupService = async (
  tenantId: string,
  serviceId: string,
  overrides: Record<string, unknown> = {},
): Promise<void> => {
  await serviceDoc(tenantId, serviceId).set({
    name: 'Haircut',
    durationMinutes: 30,
    ...overrides,
  });
};

const createBookingDoc = async (
  tenantId: string,
  overrides: Record<string, unknown> = {},
): Promise<{id: string; ref: admin.firestore.DocumentReference}> => {
  const ref = bookingsCol(tenantId).doc();
  await ref.set({
    customerName: 'Test',
    customerPhone: '+919876543210',
    serviceId: 'svc1',
    staffId: null,
    date,
    timeSlot: '09:00',
    status: 'confirmed',
    tokenId: null,
    createdAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now(),
    ...overrides,
  });
  return {id: ref.id, ref};
};

describe('getAvailableSlots', () => {
  const tenantId = 'slots-tenant';
  const serviceId = 'svc1';

  beforeEach(async () => {
    await cleanupTenant(tenantId);
    await setupTenant(tenantId);
    await setupService(tenantId, serviceId);
  });

  afterAll(async () => {
    await cleanupTenant(tenantId);
  });

  test('returns slots based on operating hours and duration', async () => {
    const result = await getAvailableSlots.run(
      mockRequest({tenantId, serviceId, date}),
    );
    expect(result.slots).toContain('09:00');
    expect(result.slots).toContain('09:30');
    expect(result.slots).toContain('16:30');
    expect(result.slots).not.toContain('17:00');
  });

  test('returns empty when operating hours not set', async () => {
    await setupTenant(tenantId, {openTime: null, closeTime: null});

    const result = await getAvailableSlots.run(
      mockRequest({tenantId, serviceId, date}),
    );
    expect(result.slots).toEqual([]);
  });

  test('excludes already booked slots', async () => {
    await createBookingDoc(tenantId, {timeSlot: '09:00', status: 'confirmed'});

    const result = await getAvailableSlots.run(
      mockRequest({tenantId, serviceId, date}),
    );
    expect(result.slots).not.toContain('09:00');
    expect(result.slots).toContain('09:30');
  });

  test('throws when tenant not found', async () => {
    await expect(
      getAvailableSlots.run(
        mockRequest({tenantId: 'missing', serviceId, date}),
      ),
    ).rejects.toThrow();
  });

  test('throws when appointments not enabled', async () => {
    await setupTenant(tenantId, {bookingMode: 'token'});

    await expect(
      getAvailableSlots.run(mockRequest({tenantId, serviceId, date})),
    ).rejects.toThrow();
  });
});

describe('createBooking', () => {
  const tenantId = 'create-tenant';
  const serviceId = 'svc1';

  beforeEach(async () => {
    await cleanupTenant(tenantId);
    await setupTenant(tenantId);
    await setupService(tenantId, serviceId);
  });

  afterAll(async () => {
    await cleanupTenant(tenantId);
  });

  test('creates a booking with status confirmed', async () => {
    const result = await createBooking.run(
      mockRequest({
        tenantId,
        customerName: 'Ravi',
        customerPhone: '+919876543210',
        serviceId,
        date,
        timeSlot: '10:00',
      }),
    );

    expect(result.id).toBeDefined();
    expect(result.entry.status).toBe('confirmed');
    expect(result.entry.customerName).toBe('Ravi');
    expect(result.entry.tokenId).toBeNull();

    const doc = await bookingsCol(tenantId).doc(result.id).get();
    expect(doc.exists).toBe(true);
    expect(doc.data()!.status).toBe('confirmed');
  });

  test('throws when slot already booked', async () => {
    await createBookingDoc(tenantId, {
      timeSlot: '10:00',
      status: 'confirmed',
    });

    await expect(
      createBooking.run(
        mockRequest({
          tenantId,
          customerName: 'Ravi',
          customerPhone: '+919876543210',
          serviceId,
          date,
          timeSlot: '10:00',
        }),
      ),
    ).rejects.toThrow();
  });

  test('throws when tenant not found', async () => {
    await expect(
      createBooking.run(
        mockRequest({
          tenantId: 'missing',
          customerName: 'Ravi',
          customerPhone: '+919876543210',
          serviceId,
          date,
          timeSlot: '10:00',
        }),
      ),
    ).rejects.toThrow();
  });

  test('throws when appointments not enabled', async () => {
    await setupTenant(tenantId, {bookingMode: 'token'});

    await expect(
      createBooking.run(
        mockRequest({
          tenantId,
          customerName: 'Ravi',
          customerPhone: '+919876543210',
          serviceId,
          date,
          timeSlot: '10:00',
        }),
      ),
    ).rejects.toThrow();
  });
});

describe('cancelBooking', () => {
  const tenantId = 'cancel-tenant';

  beforeEach(async () => {
    await cleanupTenant(tenantId);
    await setupTenant(tenantId);
  });

  afterAll(async () => {
    await cleanupTenant(tenantId);
  });

  test('cancels a confirmed booking', async () => {
    const booking = await createBookingDoc(tenantId, {
      status: 'confirmed',
    });

    const result = await cancelBooking.run(
      mockRequest({tenantId, bookingId: booking.id}),
    );

    expect(result.entry.status).toBe('cancelled');
    const doc = await bookingsCol(tenantId).doc(booking.id).get();
    expect(doc.data()!.status).toBe('cancelled');
  });

  test('throws when booking not found', async () => {
    await expect(
      cancelBooking.run(
        mockRequest({tenantId, bookingId: 'nonexistent'}),
      ),
    ).rejects.toThrow();
  });

  test('throws when not authenticated', async () => {
    const booking = await createBookingDoc(tenantId);

    await expect(
      cancelBooking.run(
        mockUnauthRequest({tenantId, bookingId: booking.id}),
      ),
    ).rejects.toThrow();
  });
});

describe('convertBookingToToken', () => {
  const tenantId = 'convert-tenant';

  beforeEach(async () => {
    await cleanupTenant(tenantId);
    await setupTenant(tenantId);
  });

  afterAll(async () => {
    await cleanupTenant(tenantId);
  });

  test('creates a token and links it to the booking', async () => {
    const booking = await createBookingDoc(tenantId, {
      status: 'confirmed',
      customerName: 'Ravi',
      customerPhone: '+919876543210',
      serviceId: 'svc1',
    });

    const result = await convertBookingToToken.run(
      mockRequest({tenantId, bookingId: booking.id}),
    );

    expect(result.entry.tokenNumber).toBe(1);
    expect(result.entry.status).toBe('waiting');
    expect(result.entry.source).toBe('app');
    expect(result.entry.bookingId).toBe(booking.id);

    const tokenDoc = await entriesCol(tenantId).doc(result.id).get();
    expect(tokenDoc.exists).toBe(true);
    expect(tokenDoc.data()!.tokenNumber).toBe(1);

    const meta = await metaDoc(tenantId).get();
    expect(meta.data()?.nextToken).toBe(2);

    const updatedBooking = await bookingsCol(tenantId)
      .doc(booking.id)
      .get();
    expect(updatedBooking.data()!.status).toBe('completed');
    expect(updatedBooking.data()!.tokenId).toBe(result.id);
  });

  test('increments daily counter across multiple conversions', async () => {
    const b1 = await createBookingDoc(tenantId, {
      status: 'confirmed',
      timeSlot: '09:00',
    });
    const b2 = await createBookingDoc(tenantId, {
      status: 'confirmed',
      timeSlot: '09:30',
    });

    const r1 = await convertBookingToToken.run(
      mockRequest({tenantId, bookingId: b1.id}),
    );
    const r2 = await convertBookingToToken.run(
      mockRequest({tenantId, bookingId: b2.id}),
    );

    expect(r1.entry.tokenNumber).toBe(1);
    expect(r2.entry.tokenNumber).toBe(2);
  });

  test('throws when booking not found', async () => {
    await expect(
      convertBookingToToken.run(
        mockRequest({tenantId, bookingId: 'nonexistent'}),
      ),
    ).rejects.toThrow();
  });

  test('throws when booking is not confirmed', async () => {
    const booking = await createBookingDoc(tenantId, {
      status: 'cancelled',
    });

    await expect(
      convertBookingToToken.run(
        mockRequest({tenantId, bookingId: booking.id}),
      ),
    ).rejects.toThrow();
  });

  test('throws when not authenticated', async () => {
    const booking = await createBookingDoc(tenantId, {
      status: 'confirmed',
    });

    await expect(
      convertBookingToToken.run(
        mockUnauthRequest({tenantId, bookingId: booking.id}),
      ),
    ).rejects.toThrow();
  });
});
