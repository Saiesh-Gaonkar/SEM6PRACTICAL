#include <Wire.h>
#include <Adafruit_BMP085.h>
#include "DHT.h"
#include "RTClib.h"

#define DHTPIN 2
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);
Adafruit_BMP085 bmp;
RTC_DS3231 rtc;

void setup() {
  Serial.begin(9600);
  dht.begin();
  if (!bmp.begin()) {
    Serial.println("Could not find a valid BMP180 sensor!");
    while (1) {}
  }
  if (!rtc.begin()) {
    Serial.println("Couldn't find RTC");
    while (1);
  }
}

void loop() {
  DateTime now = rtc.now();
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  Serial.print("Date: ");
  Serial.print(now.year(), DEC);
  Serial.print('/');
  Serial.print(now.month(), DEC);
  Serial.print('/');
  Serial.print(now.day(), DEC);
  Serial.print(" Time: ");
  Serial.print(now.hour(), DEC);
  Serial.print(':');
  Serial.print(now.minute(), DEC);
  Serial.print(" | Temp: ");
  Serial.print(t);
  Serial.print(" C");
  Serial.print(" | Hum: ");
  Serial.print(h);
  Serial.print(" %");
  Serial.print(" | Press: ");
  Serial.print(bmp.readPressure());
  Serial.println(" Pa");
  delay(2000);
}
