/**
 * Firebase Cloud Function: sendPushOnNewNotification
 *
 * Triggers when a new document is created in the `notifications` collection.
 * Reads the target user's FCM tokens from their `users/{uid}` document and
 * sends a push notification via FCM v1.
 *
 * Firestore notification document schema (written by the Flutter app):
 * {
 *   toUserId: string,        // recipient user ID
 *   fromUserName: string,     // sender display name
 *   message: string,          // notification body text
 *   messageKey: string|null,  // localization key (used client-side)
 *   messageParams: map|null,  // localization params (used client-side)
 *   type: string,             // e.g. 'leave_submitted', 'attendance_checkin'
 *   leaveId: string|null,     // related leave ID if applicable
 *   createdAt: string,        // ISO 8601 timestamp
 *   isRead: boolean,          // always false on creation
 * }
 *
 * User document schema (relevant fields):
 * {
 *   firstName: string,
 *   lastName: string,
 *   fcmTokens: string[],     // array of device FCM tokens
 * }
 */

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { logger } = require("firebase-functions");

initializeApp();

/**
 * Maps notification type to a human-readable title for the push notification.
 */
function getTitleForType(type, fromUserName) {
  switch (type) {
    case "leave_submitted":
      return "New Leave Request";
    case "leave_approved":
      return "Leave Approved";
    case "leave_rejected":
      return "Leave Rejected";
    case "leave_cancelled":
      return "Leave Cancelled";
    case "attendance_checkin":
      return "Team Check-in";
    case "attendance_checkout":
      return "Team Check-out";
    case "attendance_breakin":
      return "Team Break";
    default:
      return "Pulsera";
  }
}

exports.sendPushOnNewNotification = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn("No data in notification document.");
      return;
    }

    const notificationData = snapshot.data();
    const notificationId = event.params.notificationId;

    const toUserId = notificationData.toUserId;
    const fromUserName = notificationData.fromUserName || "Pulsera";
    const message = notificationData.message || "";
    const type = notificationData.type || "";

    if (!toUserId) {
      logger.warn("Notification has no toUserId, skipping.");
      return;
    }

    // Fetch the recipient's FCM tokens from their user document
    const db = getFirestore();
    const userDoc = await db.collection("users").doc(toUserId).get();

    if (!userDoc.exists) {
      logger.warn(`User ${toUserId} not found, skipping push.`);
      return;
    }

    const userData = userDoc.data();
    const fcmTokens = userData.fcmTokens;

    if (!fcmTokens || !Array.isArray(fcmTokens) || fcmTokens.length === 0) {
      logger.info(`User ${toUserId} has no FCM tokens, skipping push.`);
      return;
    }

    // Build the FCM message
    const title = getTitleForType(type, fromUserName);
    const messaging = getMessaging();

    // Send to each token individually so we can clean up invalid tokens
    const tokensToRemove = [];

    const sendPromises = fcmTokens.map(async (token) => {
      try {
        await messaging.send({
          token: token,
          notification: {
            title: title,
            body: message,
          },
          data: {
            notificationId: notificationId,
            type: type || "",
            fromUserName: fromUserName || "",
          },
          android: {
            notification: {
              channelId: "pulsera_notifications",
              priority: "high",
              defaultSound: true,
            },
            priority: "high",
          },
          apns: {
            payload: {
              aps: {
                alert: {
                  title: title,
                  body: message,
                },
                sound: "default",
                badge: 1,
              },
            },
          },
        });
        logger.info(`Push sent to token ${token.substring(0, 10)}...`);
      } catch (error) {
        logger.error(`Error sending to token ${token.substring(0, 10)}...`, error);
        // If the token is invalid/expired, mark it for removal
        if (
          error.code === "messaging/invalid-registration-token" ||
          error.code === "messaging/registration-token-not-registered"
        ) {
          tokensToRemove.push(token);
        }
      }
    });

    await Promise.all(sendPromises);

    // Clean up any invalid tokens from the user's document
    if (tokensToRemove.length > 0) {
      const { FieldValue } = require("firebase-admin/firestore");
      await db.collection("users").doc(toUserId).update({
        fcmTokens: FieldValue.arrayRemove(...tokensToRemove),
      });
      logger.info(`Removed ${tokensToRemove.length} invalid token(s) for user ${toUserId}.`);
    }
  }
);
