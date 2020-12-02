#include <WiFi.h>
#include <HTTPClient.h>
#include <HardwareSerial.h>

/* =============== config section start =============== */

const int BUTTON_PIN = 19;
const int LED_PIN = 18;

// WiFi credentials
const char* ssid = "FiOS-KLEIN";
const char* password = "pAf1pAg1m3L1";

String serverName = "http://esp32.kyeburchard.com/overcooked";

HardwareSerial FPGASerial(1);

/* =============== config section end =============== */

// PORTS: USB4, USB0


void setup() {
  Serial.begin(115200);
  // Set up a hardware serial at 115200 baud, transmitting 8 bits at a time
  // and with pins 22 and 23 as 
  FPGASerial.begin(115200, SERIAL_8N1, 22, 23);

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


void sendState(uint32_t val) {
  HTTPClient http;
  String route = serverName + "/playerstate";
  http.begin(route.c_str());
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  String body;
  body = String("state=") + String(val);
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
  uint32_t ack = 15;
  sendToFPGA(ack); // ACK that we finished POSTing
}

void upload() {
  uint32_t val = 0;
  if (FPGASerial.available()) {
    for (int i = 0; i < 4; i++) {
      uint8_t v = FPGASerial.read();
      Serial.print("Received from FPGA: ");
      Serial.println(v);
      val |= v << (8*i);
    }
    sendState(val);
  } else {
//    Serial.println("Nothing received from FPGA.");
  }
}


uint32_t states[4];
void fetchState() {
  HTTPClient http;
  String route = serverName + "/playerstate";
  http.begin(route.c_str());
  int respCode = http.GET();
  if (respCode > 0) {
    Serial.print("Response code: ");
    Serial.println(respCode);
    String resp = http.getString();
    Serial.print("Response: ");
    Serial.println(resp);
    states[0] = strtoul(resp.substring(0, 10).c_str(), NULL, 10);
    states[1] = strtoul(resp.substring(11, 21).c_str(), NULL, 10);
    states[2] = strtoul(resp.substring(22, 32).c_str(), NULL, 10);
    states[3] = strtoul(resp.substring(33, 43).c_str(), NULL, 10);
    Serial.println("updated local states!");
    return;
  } else {
    Serial.print("Error code: ");
    Serial.println(respCode);
    return;
  }
}

void sendToFPGA(uint32_t bytes) {
  if (FPGASerial.availableForWrite()) {
    for (int i = 0; i < 4; i++) {
      uint8_t shift = i << 3;
      uint32_t mask = 255 << shift;
      uint8_t val = (bytes & mask) >> shift;
      FPGASerial.write(val);
    }
    Serial.print("transmitted to FPGA bytes=");
    Serial.println(bytes);
  } else {
    Serial.println("FPGASerial not available for writing");
  }
}

void download() {
  fetchState();
  for (int i = 0; i < 4; i++) {
    sendToFPGA(states[i]);
  }
}


void loop() {
  // Read from FPGA and send to server
  upload();

  // Fetch from server and send to FPGA
  download();
}
