const { RtcTokenBuilder, RtcRole } = require('agora-access-token');

module.exports = (req, res) => {
  // CORS Headers
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    const appId = "6ef4712b229a4c9691633f4f6cd8d42d";
    const appCertificate = "917763fe2c1343cfb52db9f52458c5bf";
    
    const channelName = req.query.channelName || (req.body && req.body.channelName);
    const uidStr = req.query.uid || (req.body && req.body.uid) || '0';
    
    if (!channelName) {
      return res.status(400).json({ error: 'channelName is required' });
    }

    let uid = 0;
    if (uidStr && uidStr !== '0') {
      uid = parseInt(uidStr, 10);
    }

    const role = RtcRole.PUBLISHER;
    const expirationTimeInSeconds = 3600;
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channelName,
      uid,
      role,
      privilegeExpiredTs
    );

    return res.status(200).json({ token });
  } catch (error) {
    console.error('Error generating token:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};
