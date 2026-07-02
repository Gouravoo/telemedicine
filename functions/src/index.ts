import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp();

// ─── Agora Token Generation ───
export { generateAgoraToken } from "./agora/generate_token";

// ─── Notification Triggers ───
export {
  onAppointmentCreated,
  onAppointmentUpdated,
} from "./notifications/appointment_triggers";
