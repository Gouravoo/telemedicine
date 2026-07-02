import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * FCM notification trigger when a new appointment is created
 * Notifies the doctor about the new appointment request
 */
export const onAppointmentCreated = functions.firestore
  .document("appointments/{appointmentId}")
  .onCreate(async (snap, context) => {
    const appointment = snap.data();
    const doctorId = appointment.doctorId;
    const patientName = appointment.patientName;
    const timeSlot = appointment.timeSlot;

    try {
      // Get doctor's FCM token
      const doctorDoc = await db.collection("users").doc(doctorId).get();
      const fcmToken = doctorDoc.data()?.fcmToken;

      if (fcmToken) {
        await messaging.send({
          token: fcmToken,
          notification: {
            title: "New Appointment Request",
            body: `${patientName} has requested an appointment for ${timeSlot}`,
          },
          data: {
            type: "appointment_new",
            appointmentId: context.params.appointmentId,
          },
        });
      }
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  });

/**
 * FCM notification trigger when appointment status changes
 * Notifies the patient about acceptance/rejection/completion
 */
export const onAppointmentUpdated = functions.firestore
  .document("appointments/{appointmentId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only trigger on status changes
    if (before.status === after.status) return;

    const patientId = after.patientId;
    const doctorName = after.doctorName;
    const newStatus = after.status;

    let title = "";
    let body = "";

    switch (newStatus) {
      case "accepted":
        title = "Appointment Accepted! ✅";
        body = `Dr. ${doctorName} accepted your appointment for ${after.timeSlot}`;
        break;
      case "rejected":
        title = "Appointment Declined";
        body = `Your appointment request with Dr. ${doctorName} was declined`;
        break;
      case "completed":
        title = "Consultation Completed";
        body = `Your consultation with Dr. ${doctorName} is complete. View your prescription.`;
        break;
      default:
        return;
    }

    try {
      const patientDoc = await db.collection("users").doc(patientId).get();
      const fcmToken = patientDoc.data()?.fcmToken;

      if (fcmToken) {
        await messaging.send({
          token: fcmToken,
          notification: { title, body },
          data: {
            type: `appointment_${newStatus}`,
            appointmentId: context.params.appointmentId,
          },
        });
      }
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  });
