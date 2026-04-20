int pirPin = 2;
int ldrPin = A0;
int ledPin = 13;
int ldrThreshold = 400;

void setup() {
  pinMode(pirPin, INPUT);
  pinMode(ledPin, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  int ldrValue = analogRead(ldrPin);
  int pirState = digitalRead(pirPin);

  if (ldrValue < ldrThreshold) {
    if (pirState == HIGH) {
      digitalWrite(ledPin, HIGH);
    } else {
      digitalWrite(ledPin, LOW);
    }
  } else {
    digitalWrite(ledPin, LOW);
  }
  delay(100);
}
