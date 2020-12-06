#include <WiFi.h>
#include <HTTPClient.h>
#include <HardwareSerial.h>

/* =============== config section start =============== */

#define DEBUG_PRINT 1

// ONLY MAIN SHOULD HAVE THIS UNCOMMENTED
#define main

const int BUTTON_PIN = 19;
const int LED_PIN = 18;

// WiFi credentials
const char* ssid = "FiOS-KLEIN";
const char* password = "pAf1pAg1m3L1";

String serverName = "http://esp32.kyeburchard.com/overcooked";

HardwareSerial FPGASerial(1);

/* =============== config section end =============== */

// PORTS: USB0, USB2 (main)

uint32_t states[4];
uint32_t ack = 7;

#define NUM_BPACKETS 15
uint32_t local_board_state[NUM_BPACKETS];
uint32_t remote_board_state[NUM_BPACKETS];

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

// Sends an updated player state to the server and updates local states[] storage.
// If val=0, purely updates local states[].
void updatePlayerState(uint32_t val) {
  HTTPClient http;
  String route = serverName + "/playerstate";
  http.begin(route.c_str());
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  String body;
  body = String("player_state=") + String(val);
#if DEBUG_PRINT == 1
  Serial.print("sending player POST to server ");
  Serial.println(body);
#endif
  int respCode = http.POST(body);
  if (respCode > 0) {
    String resp = http.getString();
    Serial.print("Response: ");
    Serial.println(resp);
    states[0] = strtoul(resp.substring(0, 10).c_str(), NULL, 10);
    states[1] = strtoul(resp.substring(11, 21).c_str(), NULL, 10);
    states[2] = strtoul(resp.substring(22, 32).c_str(), NULL, 10);
    states[3] = strtoul(resp.substring(33, 43).c_str(), NULL, 10);
  } else {
    Serial.print("Error code: ");
    Serial.println(respCode);
  }

  // only ack if non-trivial data was sent
  if (val != 0) {
    sendToFPGA(ack); // ACK that we finished POSTing
  }
}

void updateBoardState() {
  for (int i = 0; i < NUM_BPACKETS; i++) {
    uint32_t val = 0;
    for (int i = 0; i < 4; i++) {
      while (!FPGASerial.available()) {} // wait for available
      uint8_t v = FPGASerial.read();
      val |= v << (8*i);
    }
    local_board_state[i] = val;
  }
}

void sendBoardState() {
  HTTPClient http;
  String route = serverName + "/boardstate";
  http.begin(route.c_str());
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  String body;
  body = String("board_state=");

  for (int i = 0; i < NUM_BPACKETS; i++) {
    char buf[50];
    snprintf(buf, 50, "%010u", local_board_state[i]);
    body = body + String(buf) + String('|');
  }
#if DEBUG_PRINT == 1
  Serial.print("sending board POST to server ");
  Serial.println(body);
#endif
  int respCode = http.POST(body);  
  if (respCode > 0) {
    String resp = http.getString();
    Serial.print("Response: ");
    Serial.println(resp);
  } else {
    Serial.print("Error code: ");
    Serial.println(respCode);
  }

  sendToFPGA(ack); // ACK that we finished POSTing
}

void getBoardState() {
  HTTPClient http;
  String route = serverName + "/boardstate";
  http.begin(route.c_str());
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  String body;
  body = String("board_state=none");
#if DEBUG_PRINT == 1
  Serial.print("sending board POST (but actually this is a get) to server ");
  Serial.println(body);
#endif
  int respCode = http.POST(body);  
  if (respCode > 0) {
    String resp = http.getString();
    Serial.print("Response: ");
    Serial.println(resp);
    
    remote_board_state[0] = strtoul(resp.substring(0, 10).c_str(), NULL, 10);
    remote_board_state[1] = strtoul(resp.substring(11, 21).c_str(), NULL, 10);
    remote_board_state[2] = strtoul(resp.substring(22, 32).c_str(), NULL, 10);
    remote_board_state[3] = strtoul(resp.substring(33, 43).c_str(), NULL, 10);
    remote_board_state[4] = strtoul(resp.substring(44, 54).c_str(), NULL, 10);
    remote_board_state[5] = strtoul(resp.substring(55, 65).c_str(), NULL, 10);
    remote_board_state[6] = strtoul(resp.substring(66, 76).c_str(), NULL, 10);
    remote_board_state[7] = strtoul(resp.substring(77, 87).c_str(), NULL, 10);
    remote_board_state[8] = strtoul(resp.substring(88, 98).c_str(), NULL, 10);
    remote_board_state[9] = strtoul(resp.substring(99, 109).c_str(), NULL, 10);
    remote_board_state[10] = strtoul(resp.substring(110, 120).c_str(), NULL, 10);
    remote_board_state[11] = strtoul(resp.substring(121, 131).c_str(), NULL, 10);
    remote_board_state[12] = strtoul(resp.substring(132, 142).c_str(), NULL, 10);
    remote_board_state[13] = strtoul(resp.substring(143, 153).c_str(), NULL, 10);
    remote_board_state[14] = strtoul(resp.substring(154, 164).c_str(), NULL, 10);
    remote_board_state[15] = strtoul(resp.substring(165, 175).c_str(), NULL, 10);

    for (int i = 0; i < NUM_BPACKETS; i++) {
      Serial.print("Sending board packet to FPGA: ");
      Serial.println(remote_board_state[i]);
      sendToFPGA(remote_board_state[i]);
    }
    
    } else {
    Serial.print("Error code: ");
    Serial.println(respCode);
  }
}

#define DTYPE_START_BSTATE 1
void upload() {
  uint32_t val = 0;
  if (FPGASerial.available()) {
    for (int i = 0; i < 4; i++) {
      uint8_t v = FPGASerial.read();
      val |= v << (8*i);
    }
    if (val == DTYPE_START_BSTATE) { // magic num indicating start of board state
      updateBoardState();
      sendBoardState();
      val = 0;
    } else {
      updatePlayerState(val);
    }
  }
  updatePlayerState(val);
}

void sendToFPGA(uint32_t bytes) {
  if (FPGASerial.availableForWrite()) {
    for (int i = 0; i < 4; i++) {
      uint8_t shift = i << 3;
      uint32_t mask = 255 << shift;
      uint8_t val = (bytes & mask) >> shift;
      FPGASerial.write(val);
    }
  } else {
    Serial.println("FPGASerial not available for writing");
  }
}

void download() {
  for (int i = 0; i < 4; i++) {
    sendToFPGA(states[i]);
  }
}


void loop() {
  // Read from FPGA and send to server
  upload();

  // Send player state to FPGA
  download();

#ifndef main
  // download and send board state to FPGA
  getBoardState();
#endif
}
