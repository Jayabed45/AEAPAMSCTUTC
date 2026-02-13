const {
    onDocumentCreated,
    onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

admin.initializeApp();

/**
 * Triggers when a new notification is added to the 'notifications' collection.
 * Broadcasts it to all registered device tokens across all users.
 */
exports.broadcastNotification = onDocumentCreated(
    "notifications/{notificationId}",
    async (event) => {
        const snapshot = event.data;
        if (!snapshot) {
            logger.error("No data associated with the event");
            return;
        }

        const notification = snapshot.data();
        const title = notification.title || "New Alert";
        const body = notification.description || "System notification received.";

        logger.info(`Broadcasting notification: ${title}`);

        try {
            const tokens = [];
            const usersSnapshot = await admin.firestore().collection("users").get();

            for (const userDoc of usersSnapshot.docs) {
                const tokensSnapshot = await userDoc.ref.collection("tokens").get();
                tokensSnapshot.forEach((tokenDoc) => {
                    const data = tokenDoc.data();
                    if (data.token) {
                        tokens.push(data.token);
                    }
                });
            }

            if (tokens.length === 0) {
                logger.info("No tokens found to notify.");
                return;
            }

            const message = {
                notification: {
                    title: title,
                    body: body,
                },
                android: {
                    notification: {
                        channelId: "high_importance_channel",
                        priority: "high",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: "default",
                            badge: 1,
                        },
                    },
                },
                tokens: tokens,
            };

            const response = await admin.messaging().sendEachForMulticast(message);
            logger.info(`Successfully sent ${response.successCount} messages.`);
        } catch (error) {
            logger.error("Error broadcasting notification:", error);
        }
    });

/**
 * Triggers when system data is updated.
 * Automatically creates a notification document if anomalies are detected.
 */
exports.checkSystemAnomalies = onDocumentUpdated(
    "system/current_data",
    async (event) => {
        const newData = event.data.after.data();
        const oldData = event.data.before.data();

        if (!newData) return;

        const anomalies = [];

        // 1. Temperature Check (> 50°C)
        if (newData.temperature > 50.0 &&
            (!oldData || oldData.temperature <= 50.0)) {
            anomalies.push({
                title: "Critical Temperature Alert",
                description: `System temperature has reached ${newData.temperature}°C!`,
                icon_name: "thermostat_rounded",
                icon_color_hex: "#F44336",
            });
        }

        // 2. Daily Liters Check (> 500L)
        if (newData.daily_liters > 500 && (!oldData || oldData.daily_liters <= 500)) {
            anomalies.push({
                title: "Daily Water Limit",
                description: `Daily water usage has exceeded ${newData.daily_liters}L.`,
                icon_name: "water_drop_rounded",
                icon_color_hex: "#F44336",
            });
        }

        // 3. Voltage Check (> 250V)
        if (newData.voltage > 250.0 && (!oldData || oldData.voltage <= 250.0)) {
            anomalies.push({
                title: "Overvoltage Alert",
                description: `Voltage surge detected: ${newData.voltage}V.`,
                icon_name: "bolt",
                icon_color_hex: "#F44336",
            });
        }

        for (const anomaly of anomalies) {
            await admin.firestore().collection("notifications").add({
                ...anomaly,
                time: "Just Now",
                is_unread: true,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
    });
