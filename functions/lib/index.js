"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onAppointmentUpdated = exports.onAppointmentCreated = exports.generateAgoraToken = void 0;
const admin = require("firebase-admin");
// Initialize Firebase Admin
admin.initializeApp();
// ─── Agora Token Generation ───
var generate_token_1 = require("./agora/generate_token");
Object.defineProperty(exports, "generateAgoraToken", { enumerable: true, get: function () { return generate_token_1.generateAgoraToken; } });
// ─── Notification Triggers ───
var appointment_triggers_1 = require("./notifications/appointment_triggers");
Object.defineProperty(exports, "onAppointmentCreated", { enumerable: true, get: function () { return appointment_triggers_1.onAppointmentCreated; } });
Object.defineProperty(exports, "onAppointmentUpdated", { enumerable: true, get: function () { return appointment_triggers_1.onAppointmentUpdated; } });
//# sourceMappingURL=index.js.map