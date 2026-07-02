const admin = require('firebase-admin');

// 1. Download your service account key from Firebase Console -> Project Settings -> Service Accounts
// 2. Save it as 'serviceAccountKey.json' in this folder
// 3. Run: node seed_doctors.js

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

async function seedDoctors() {
  const doctors = [
    {
      email: 'doctor1@aarogyaplus.com',
      password: 'password123',
      name: 'Dr. Santosh Kumar Singh',
      specialty: 'Cardiologist',
      photoUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=2070&auto=format&fit=crop',
      experienceYears: 15,
      consultationFee: 1200,
      qualifications: 'MBBS, MD (Cardiology)',
      bio: 'Renowned Cardiologist with 15+ years of experience in interventional cardiology.',
    },
    {
      email: 'doctor2@aarogyaplus.com',
      password: 'password123',
      name: 'Dr. Neha Sharma',
      specialty: 'Dermatologist',
      photoUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?q=80&w=2070&auto=format&fit=crop',
      experienceYears: 10,
      consultationFee: 800,
      qualifications: 'MBBS, MD (Dermatology)',
      bio: 'Expert Dermatologist specializing in clinical and cosmetic dermatology.',
    }
  ];

  for (const doc of doctors) {
    try {
      // 1. Create User in Firebase Auth
      const userRecord = await auth.createUser({
        email: doc.email,
        password: doc.password,
        displayName: doc.name,
      });

      console.log(`Created user: ${userRecord.uid}`);

      // 2. Add to 'users' collection with role 'doctor'
      await db.collection('users').doc(userRecord.uid).set({
        uid: userRecord.uid,
        email: doc.email,
        name: doc.name,
        role: 'doctor',
        createdAt: new Date().toISOString()
      });

      // 3. Add to 'doctors' collection
      await db.collection('doctors').doc(userRecord.uid).set({
        id: userRecord.uid,
        name: doc.name,
        email: doc.email,
        specialty: doc.specialty,
        photoUrl: doc.photoUrl,
        experienceYears: doc.experienceYears,
        consultationFee: doc.consultationFee,
        qualifications: doc.qualifications,
        bio: doc.bio,
        rating: 5.0,
        ratingCount: 120,
        isActive: true,
        availability: {}
      });

      console.log(`Successfully seeded ${doc.name}`);
    } catch (e) {
      console.error(`Error creating ${doc.name}:`, e.message);
    }
  }
}

seedDoctors().then(() => process.exit(0));
