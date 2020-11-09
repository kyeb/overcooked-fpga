#include <WiFi.h>
#include <HTTPClient.h>

/* =============== config section start =============== */

#define DEV_TYPE 1    // "0" for primary, and "1" for others

const int BUTTON_PIN = 32;
const int LED_PIN = 22;

// WiFi credentials
const char* ssid = "MIT";
const char* password = "";

String serverName = "http://esp32.kyeburchard.com/overcooked";

/* =============== config section end =============== */


void setup() {
  Serial.begin(115200);

  pinMode(BUTTON_PIN, INPUT_PULLUP);

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  // attempt wifi connection
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print("Attempting to connect to ");
    Serial.print(ssid);
    WiFi.begin(ssid, password);
    for (int j = 0; j < 10; j++) {
      if (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
      } else {
        Serial.println("Connected!");
        Serial.print("IP address: ");
        Serial.println(WiFi.localIP());
        break;
      }
    }
  }
}


void sendPressed(int pressed) {
  Serial.print("pressed: ");
  Serial.println(pressed);
  HTTPClient http;
  String route = serverName + "/button";
  http.begin(route.c_str());
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  String body;
  if (pressed) {
    body = "pressed=1";
  } else {
    body = "pressed=0";
  }
  int respCode = http.POST(body);
  if (respCode > 0) {
    Serial.print("Response: ");
    Serial.println(respCode);
    Serial.println(http.getString());
  } else {
    Serial.print("Error code: ");
    Serial.println(respCode);
  }
}


int fetchPressed() {
  HTTPClient http;
  String route = serverName + "/button";
  http.begin(route.c_str());
  int respCode = http.GET();
  if (respCode > 0) {
    Serial.print("Response: ");
    Serial.println(respCode);
    String resp = http.getString();
    Serial.println(resp);
    return resp.toInt();
  } else {
    Serial.print("Error code: ");
    Serial.println(respCode);
    return 0;
  }
}


enum State {IDLE, SEND, WAIT};
State state = IDLE;

int prev;
void loop() {
#if DEV_TYPE == 0
  int b = digitalRead(BUTTON_PIN);
  if (b != prev) {
    if (b == LOW) {
      sendPressed(1);
    } else {
      sendPressed(0);
    }
  }
  prev = b;
#else
  int b = fetchPressed();
  if (b) {
    digitalWrite(LED_PIN, HIGH);
  } else {
    digitalWrite(LED_PIN, LOW);
  }
#endif
}
