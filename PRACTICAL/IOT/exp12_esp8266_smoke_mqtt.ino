#include <ESP8266WiFi.h>
#include <PubSubClient.h>

const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
const char* mqtt_server = "BROKER_IP_ADDRESS";

WiFiClient espClient;
PubSubClient client(espClient);

const int sensorPin = D1;

void setup() {
  pinMode(sensorPin, INPUT);
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }
  client.setServer(mqtt_server, 1883);
}

void loop() {
  if (!client.connected()) {
    client.connect("ESP8266_SmokeClient");
  }
  client.loop();

  int sensorState = digitalRead(sensorPin);
  if (sensorState == LOW) {
    client.publish("home/sensors/smoke", "SMOKE DETECTED!");
  } else {
    client.publish("home/sensors/smoke", "CLEAR");
  }
  delay(2000);
}
