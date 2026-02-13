#include <Arduino.h>
#include <WiFi.h>
#include <WiFiManager.h>
#include <Firebase_ESP_Client.h>
#include <time.h>

// Provide the token generation process info.
#include <addons/TokenHelper.h>

/* 1. Define the API Key */
#define API_KEY "AIzaSyDf1Lgnzb9xEnsuc66wl5JG1o3jEhx6x3U"

/* 2. Define the project ID */
#define FIREBASE_PROJECT_ID "aeapamsctutc"

/* 3. Define the user Email and password that allowed to write to Firestore */
/* These should be a user registered in your app */
#define USER_EMAIL "sample@gmail.com"
#define USER_PASSWORD "112233"

/* 4. Sensor Pins */
#define FLOW_SENSOR_PIN 18 // Digital pin for YF-S201 Flow Sensor

// Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Flow Sensor Variables
volatile long pulseCount = 0;
float flowRate = 0.0;
float totalLiters = 0.0;
unsigned long oldTime = 0;

void IRAM_ATTR pulseCounter() {
  pulseCount++;
}

unsigned long sendDataPrevMillis = 0;

void setup() {
  Serial.begin(115200);
  
  // Set CPU to max frequency for faster SSL handshakes
  setCpuFrequencyMhz(240);

  // Initialize Flow Sensor
  pinMode(FLOW_SENSOR_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(FLOW_SENSOR_PIN), pulseCounter, FALLING);

  // WiFiManager
  // Local intialization. Once its business is done, there is no need to keep it around
  WiFiManager wm;

  // Fetches ssid and pass and tries to connect
  // If it does not connect it starts an access point with the specified name
  // and goes into a blocking loop awaiting configuration
  if (!wm.autoConnect("AEAPAM_Device_Setup")) {
    Serial.println("Failed to connect and hit timeout");
    ESP.restart();
  }

  // Disable WiFi sleep for better SSL stability
  WiFi.setSleep(false);

  Serial.println("Connected to WiFi :)");

  // Force DNS to Google's public DNS to avoid "DNS Failed" errors
  IPAddress dns(8, 8, 8, 8);
  WiFi.config(WiFi.localIP(), WiFi.gatewayIP(), WiFi.subnetMask(), dns);

  // Synchronize time (Required for SSL certificate validation)
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  Serial.print("Waiting for NTP time sync: ");
  time_t now = time(nullptr);
  while (now < 8 * 3600 * 2) {
    delay(500);
    Serial.print(".");
    now = time(nullptr);
  }
  Serial.println("");
  struct tm timeinfo;
  gmtime_r(&now, &timeinfo);
  Serial.print("Current time: ");
  Serial.print(asctime(&timeinfo));

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback;

  // Initialize Firebase
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  
  // Set SSL connection timeout and buffer sizes
  fbdo.setResponseSize(4096);
  fbdo.setBSSLBufferSize(2048, 2048);
  config.timeout.serverResponse = 15 * 1000; // 15 seconds timeout
  config.timeout.networkReconnect = 10 * 1000;
}

void loop() {
  // Calculate Flow Rate every 1 second
  if ((millis() - oldTime) > 1000) {
    detachInterrupt(digitalPinToInterrupt(FLOW_SENSOR_PIN));
    
    // YF-S201 formula: Flow rate (L/min) = Pulse frequency / 7.5
    flowRate = ((1000.0 / (millis() - oldTime)) * pulseCount) / 7.5;
    
    oldTime = millis();
    
    // Liters = (FlowRate L/min) / 60 seconds
    totalLiters += (flowRate / 60.0);
    
    pulseCount = 0;
    attachInterrupt(digitalPinToInterrupt(FLOW_SENSOR_PIN), pulseCounter, FALLING);
  }

  // Send data every 10 seconds
  if (Firebase.ready() && (millis() - sendDataPrevMillis > 10000 || sendDataPrevMillis == 0)) {
    sendDataPrevMillis = millis();

    Serial.println("Updating system data...");

    FirebaseJson content;

    // Simulate sensor readings - Replace these with your actual sensor code
    double voltage = 220.0 + random(-5, 5);
    double current = 1.5 + (random(0, 100) / 100.0);
    double power = voltage * current;
    double temperature = 25.0 + (random(0, 50) / 10.0);
    double energy_hour = 0.5;
    double daily_energy = 12.4;
    String status = "Normal";

    // Set fields matching SystemDataModel.dart with Firestore field structure
    content.set("fields/voltage/doubleValue", voltage);
    content.set("fields/current/doubleValue", current);
    content.set("fields/power/doubleValue", power);
    content.set("fields/temperature/doubleValue", temperature);
    content.set("fields/daily_liters/doubleValue", totalLiters);
    content.set("fields/energy_hour/doubleValue", energy_hour);
    content.set("fields/daily_energy/doubleValue", daily_energy);
    content.set("fields/status/stringValue", status);

    // Path: system/current_data
    String path = "system/current_data";

    if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", path.c_str(), content.raw(), "")) {
      Serial.printf("Success. Liters: %.2f L\n", totalLiters);
    } else {
      Serial.print("Error: ");
      Serial.println(fbdo.errorReason().c_str());
    }
  }
}
