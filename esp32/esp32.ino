#include <WiFi.h>
#include <HTTPClient.h>
#include <HardwareSerial.h>

/* =============== config section start =============== */

const int BUTTON_PIN = 19;
const int LED_PIN = 18;

// WiFi credentials
const char* ssid = "MIT";
const char* password = "";

String serverName = "http://esp32.kyeburchard.com/overcooked";

HardwareSerial FPGASerial(1);

/* =============== config section end =============== */

// PORTS: USB0, USB1


void setup() {
  Serial.begin(115200);
  // Set up a hardware serial at 115200 baud, transmitting 8 bits at a time
  // and with pins 22 and 23 as 
  FPGASerial.begin(115200, SERIAL_8N1, 22, 23);

  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);

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


void sendState(uint32_t val) {
  HTTPClient http;
  String route = serverName + "/button";
  http.begin(route.c_str());
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  String body;
  body = String("pressed=") + String(val);
  Serial.print("sending POST to server ");
  Serial.println(body);
  // TODO: can this be nonblocking??
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

#define NUM_BYTES 4
void upload() {
  uint32_t val = 0;
  if (FPGASerial.available()) {
    for (int i = 0; i < NUM_BYTES; i++) {
      uint8_t v = FPGASerial.read();
      Serial.print("Received from FPGA: ");
      Serial.println(v);
      val |= v << (8*i);
    }
    sendState(val);
  }
}


uint32_t fetchState() {
  HTTPClient http;
  String route = serverName + "/button";
  http.begin(route.c_str());
  int respCode = http.GET();
  if (respCode > 0) {
    Serial.print("Response code: ");
    Serial.println(respCode);
    String resp = http.getString();
    uint32_t num = strtoul(resp.c_str(), NULL, 10);
    Serial.print("Response: ");
    Serial.println(num);
    return num;
  } else {
    Serial.print("Error code: ");
    Serial.println(respCode);
    return 0;
  }
}


void download() {
  uint32_t val = fetchState();
  digitalWrite(LED_PIN, (bool)val);
  if (FPGASerial.availableForWrite()) {
    for (int i = 0; i < NUM_BYTES; i++) {
      uint8_t shift = i << 3;
      uint32_t mask = 255 << shift;
      uint8_t num = (val & mask) >> shift;
      FPGASerial.write(num);
    }
    Serial.print("transmitted to FPGA x=");
    Serial.println(val);
  } else {
    Serial.println("FPGASerial not available for writing");
  }
}


void loop() {
  // Read from FPGA and send to server
  upload();

  // Fetch from server and send to FPGA
  download();
  delay(100);
}
