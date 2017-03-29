/**
 * ham_klok_utikity. 
 *
 * portIndex must be set to the port connected to the Arduino
 *
 * Add the controlP5 library (Menu: Schets -> Bibliotheek Importeren -> Bibliotheek Toevoegen ... Filter: "ControlP5")
 * 
 */


import processing.serial.*;
import java.util.Date;
import controlP5.*;

ControlP5 cp5;

public static final short portIndex = 0;  
Serial myPort; 
Textarea lblStatus;

long txTimer = 0;
long txTime = 1500;
boolean timeSet = false;
boolean txBusy = true;

void setup() {  
  size(350, 140);

  cp5 = new ControlP5(this);
  
  cp5.addTextlabel("label")
     .setText("Callsign:")
     .setPosition(10,20)
     .setColor(color(0))
     .setFont(createFont("arial",20))
     ;
  
  cp5.addTextfield("Callsign")
     .setPosition(100,10)
     .setSize(150,40)
     .setFont(createFont("arial",20))
     .setAutoClear(false)
     .setColor(color(0))
     .setColorBackground(color(255))
     .setColorForeground(color(0,0,255))
     .setColorCursor(color(0))
     .setLabel("")
     ;

  cp5.addBang("setCall")
     .setPosition(260,10)
     .setSize(80,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(createFont("arial",15))
     ;    

  cp5.addBang("setTime")
     .setPosition(10,60)
     .setSize(90,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(createFont("arial",15))
     ;    

  cp5.addBang("ddMMMyyyy")
     .setPosition(110,60)
     .setSize(110,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(createFont("arial",15))
     ;    

  cp5.addBang("dd_mm_yyyy")
     .setPosition(230,60)
     .setSize(110,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(createFont("arial",15))
     ;    

  lblStatus = cp5.addTextarea("status")
                  .setPosition(0,120)
                  .setSize(350,20)
                  .setFont(createFont("arial",15))
                  .setLineHeight(14)
                  .setColor(color(128))
                  .setColorBackground(color(255,100))
                  .setColorForeground(color(255,100))
     .setText("First connect HAM clock, then restart.")
                  ;
  
  printArray(Serial.list());
  println("Connecting to -> " + Serial.list()[portIndex]);
  myPort = new Serial(this,Serial.list()[portIndex], 9600);

  txTimer = millis();
}

void draw() {
  rxMessage();
  long currentMillis = millis();
  if (txBusy) {
    if ((currentMillis - txTimer) > txTime) {
      txBusy = false;
      if (!timeSet) {
        sendMessage( "T", getUtcTime());
        timeSet = true;
      }  
      lblStatus.setText("ready");
    }
  }
}

public void setCall() {
  sendMessage("call", cp5.get(Textfield.class,"Callsign").getText());
}

public void setTime() {
  sendMessage( "T", getUtcTime());
}


public void ddMMMyyyy() {
  sendMessage( "df"  , "ddMMMyyyy");
}

public void dd_mm_yyyy() {
  sendMessage( "df"  , "dd_mm_yyyy");
}

void rxMessage() {
  if ( myPort.available() > 0) {  
    char val = char(myPort.read());
    print(val); 
  }  
}

void sendMessage(String cmd, String par) {
  if (!txBusy) {
    lblStatus.setText("tx data");
    txBusy = true;
    long currentMillis = millis();
    txTimer = currentMillis;
    myPort.write(cmd + " " + par);
  }
}

String getUtcTime(){
  Date d = new Date();
  long current = d.getTime()/1000;
  return String.valueOf(current);
}