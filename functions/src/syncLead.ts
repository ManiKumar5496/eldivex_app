import { onDocumentCreated } from 'firebase-functions/v2/firestore';

const API_BASE = process.env.API_BASE_URL ?? 'https://api.eldivex.com/api';

/**
 * Triggered when a new lead document is created in Firestore.
 * If the website's direct API call failed (api_synced === false),
 * this function retries the sync to the MySQL backend.
 */
export const syncLeadToBackend = onDocumentCreated('leads/{leadId}', async (event) => {
  const data = event.data?.data();
  if (!data || data.api_synced === true) return; // already synced by the website

  try {
    const res = await fetch(`${API_BASE}/leads/capture`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name:              data.name,
        phone:             data.phone,
        email:             data.email ?? null,
        city:              data.city  ?? null,
        service_enquired:  data.service_enquired ?? null,
        message:           data.message ?? null,
      }),
    });

    if (!res.ok) {
      console.error(`syncLeadToBackend: API returned ${res.status}`);
      return;
    }

    const body = await res.json() as { success: boolean; lead_id: number };
    await event.data?.ref.update({
      api_synced:      true,
      backend_lead_id: body.lead_id,
    });

    console.log(`syncLeadToBackend: lead ${event.params.leadId} synced → backend id ${body.lead_id}`);
  } catch (err) {
    console.error('syncLeadToBackend error:', err);
    // Firebase Functions will retry on next invocation if configured
  }
});
