import * as admin from 'firebase-admin';

const projectId = process.env.GCLOUD_PROJECT || 'qcut-test';

if (admin.apps.length === 0) {
  admin.initializeApp({projectId});
}

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
