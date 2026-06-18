import * as admin from 'firebase-admin';

/**
 * Finds FCM tokens for customers whose tokens are within 2 positions of
 * the currently called token. These customers should be notified that
 * their turn is near.
 *
 * @param {string} tenantId - The tenant ID.
 * @param {string} date - The date string in YYYY-MM-DD format.
 * @param {number} currentTokenNumber - The token number that was just called.
 * @return {Promise<string[]>} Flat list of FCM registration tokens.
 */
export async function getTokensToNotify(
  tenantId: string,
  date: string,
  currentTokenNumber: number,
): Promise<string[]> {
  const entries = await admin
    .firestore()
    .collection(`tenants/${tenantId}/tokens/${date}/entries`)
    .where('status', 'in', ['waiting', 'called'])
    .where('tokenNumber', '>=', currentTokenNumber)
    .where('tokenNumber', '<=', currentTokenNumber + 2)
    .get();

  const tokens: string[] = [];
  for (const doc of entries.docs) {
    const data = doc.data();
    const phone = data.customerPhone as string;
    if (phone) {
      const user = await admin
        .firestore()
        .collection('users')
        .where('phone', '==', phone)
        .limit(1)
        .get();
      if (!user.empty) {
        const userData = user.docs[0].data();
        const fcmTokens = (userData.fcmTokens ?? []) as string[];
        tokens.push(...fcmTokens);
      }
    }
  }
  return tokens;
}

/**
 * Sends an FCM multicast message to customers whose tokens are within 2
 * positions of the currently called token, notifying them that their
 * turn is near.
 *
 * @param {string} tenantId - The tenant ID.
 * @param {string} date - The date string in YYYY-MM-DD format.
 * @param {number} currentTokenNumber - The token number that was just called.
 * @return {Promise<void>}
 */
export async function sendTokenNotification(
  tenantId: string,
  date: string,
  currentTokenNumber: number,
): Promise<void> {
  const tokens = await getTokensToNotify(tenantId, date, currentTokenNumber);
  if (tokens.length === 0) return;

  const message = {
    tokens,
    notification: {
      title: 'Your turn is near',
      body: `Token ${currentTokenNumber + 2} is being served. Please be ready.`,
    },
    data: {
      tenantId,
      date,
      currentTokenNumber: String(currentTokenNumber),
    },
  };

  const response = await admin.messaging().sendEachForMulticast(message);
  console.log(
    `Sent FCM: ${response.successCount} success, ` +
      `${response.failureCount} failures`,
  );
}
