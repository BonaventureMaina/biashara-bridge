import * as functions from 'firebase-functions';
import axios from 'axios';

const CONSUMER_KEY = process.env.DARAJA_CONSUMER_KEY;
const CONSUMER_SECRET = process.env.DARAJA_CONSUMER_SECRET;
const PASSKEY = process.env.DARAJA_PASSKEY;
const SHORTCODE = process.env.DARAJA_SHORTCODE;
const BASE_URL = 'https://sandbox.safaricom.co.ke';

// Convert 07xx or +2547xx to 2547xxxxxxxx
function formatPhoneNumber(raw: string): string {
  let cleaned = raw.replace(/\D/g, '');
  if (cleaned.startsWith('0')) {
    cleaned = '254' + cleaned.substring(1);
  } else if (cleaned.startsWith('+254')) {
    cleaned = cleaned.substring(1);
  }
  return cleaned;
}

export const initiatePayment = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  const { phoneNumber, amount, accountReference, transactionDesc } = req.body;
  if (!phoneNumber || !amount) {
    res.status(400).json({ error: 'Missing phoneNumber or amount' });
    return;
  }

  const formattedPhone = formatPhoneNumber(phoneNumber);

  const auth = Buffer.from(`${CONSUMER_KEY}:${CONSUMER_SECRET}`).toString('base64');
  let tokenResponse;
  try {
    tokenResponse = await axios.get(
      `${BASE_URL}/oauth/v1/generate?grant_type=client_credentials`,
      { headers: { Authorization: `Basic ${auth}` } }
    );
  } catch (err: any) {
    console.error('Token error:', err.message);
    res.status(500).json({ error: 'Failed to get M-Pesa token' });
    return;
  }
  const accessToken = tokenResponse.data.access_token;

  const timestamp = new Date().toISOString().replace(/[-:T.]/g, '').substring(0, 14);
  const password = Buffer.from(`${SHORTCODE}${PASSKEY}${timestamp}`).toString('base64');

  const stkPayload = {
    BusinessShortCode: SHORTCODE,
    Password: password,
    Timestamp: timestamp,
    TransactionType: 'CustomerPayBillOnline',
    Amount: Math.round(amount).toString(),
    PartyA: formattedPhone,
    PartyB: SHORTCODE,
    PhoneNumber: formattedPhone,
    CallBackURL: 'https://example.com/callback',
    AccountReference: accountReference || 'Invoice',
    TransactionDesc: transactionDesc || 'Payment via Biashara Bridge',
  };

  console.log('Sending STK Push:', JSON.stringify(stkPayload));

  try {
    const stkResponse = await axios.post(
      `${BASE_URL}/mpesa/stkpush/v1/processrequest`,
      stkPayload,
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
      }
    );
    const checkoutRequestID = stkResponse.data.CheckoutRequestID;
    if (!checkoutRequestID) {
      throw new Error(stkResponse.data.ResponseDescription || 'STK push failed');
    }
    res.json({ checkoutRequestID });
  } catch (err: any) {
    console.error('STK push error:', err.message);
    if (err.response) {
      console.error('Response data:', JSON.stringify(err.response.data));
    }
    res.status(500).json({ error: 'STK push failed: ' + err.message });
  }
});
