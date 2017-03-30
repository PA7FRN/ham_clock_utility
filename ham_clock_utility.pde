/**
 * ham_clock_utility. 
 *
 * portIndex must be set to the port connected to the Arduino
 *
 * Add the controlP5 library (Menu: Schets -> Bibliotheek Importeren -> Bibliotheek Toevoegen ... Filter: "ControlP5")
 * 
 */


import processing.serial.*;
import java.util.Date;
import controlP5.*;

public static final int COMPORT_ROW  =  10;
public static final int CALLSIGN_ROW = 120; //  10;
public static final int DATETIME_ROW = 170; //  60;
public static final int STATUS_ROW   = 230; // 120;


ControlP5 cp5;

Serial myPort; 
Textarea lblStatus;

long txTimer = 0;
long txTime = 1500;
boolean comConnected = false;
boolean timeSet = false;
boolean txBusy = true;

void setup() {  
  size(350, 250);
  PFont font = createFont("arial",20);
  PFont buttonFont = createFont("arial",15);

  cp5 = new ControlP5(this);
  
  cp5.addScrollableList("dropdown")
     .setPosition(100, COMPORT_ROW)
     .setSize(200, 100)
     .setBarHeight(22)
     .setItemHeight(22)
     .setFont(buttonFont)
     .setColorActive(color(150,150,255))
     .setColorBackground(color(255))
     .setColorForeground(color(128,128,255))
     .setColorCaptionLabel(color(0))
     .setColorLabel(color(0))
     .setColorValue(color(0))
     .setColorValueLabel(color(0))
     .addItems(Serial.list())
     ; 

  cp5.addTextlabel("label")
     .setText("Callsign:")
     .setPosition(10,CALLSIGN_ROW+10)
     .setColor(color(0))
     .setFont(font)
     ;
  
  cp5.addTextfield("Callsign")
     .setPosition(100,CALLSIGN_ROW)
     .setSize(150,40)
     .setFont(font)
     .setAutoClear(false)
     .setColor(color(0))
     .setColorBackground(color(255))
     .setColorForeground(color(0,0,255))
     .setColorCursor(color(0))
     .setLabel("")
     ;

  cp5.addBang("setCall")
     .setPosition(260,CALLSIGN_ROW)
     .setSize(80,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(buttonFont)
     ;    

  cp5.addBang("setTime")
     .setPosition(10,DATETIME_ROW)
     .setSize(90,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(buttonFont)
     ;    

  cp5.addBang("ddMMMyyyy")
     .setPosition(110,DATETIME_ROW)
     .setSize(110,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(buttonFont)
     ;    

  cp5.addBang("dd_mm_yyyy")
     .setPosition(230,DATETIME_ROW)
     .setSize(110,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(buttonFont)
     ;    

  lblStatus = cp5.addTextarea("status")
                 .setPosition(0,STATUS_ROW)
                 .setSize(350,20)
                 .setFont(buttonFont)
                 .setLineHeight(14)
                 .setColor(color(128))
                 .setColorBackground(color(255,100))
                 .setColorForeground(color(255,100))
                 .setText("First connect HAM clock, then select COM-port.")
                 ;
}

void draw() {
  background(240);
  if (comConnected) {
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
}

void dropdown(int n) {
  if (comConnected) {
    txBusy = true;
    comConnected = false;
    timeSet = false;
    txTimer = 0;
    myPort.clear();
    myPort.stop();
  }
  println("-----------------------------");
  printArray(Serial.list());
  println("Connecting to -> " + Serial.list()[n]);
  println(cp5.get(ScrollableList.class, "dropdown").getItem(n).get("text"));
  println("-----------------------------");
  myPort = new Serial(this,Serial.list()[n], 9600);
  comConnected = true;
  txTimer = millis();
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
  if (comConnected) {
    if (!txBusy) {
      lblStatus.setText("tx data");
      txBusy = true;
      long currentMillis = millis();
      txTimer = currentMillis;
      myPort.write(cmd + " " + par);
    }
  }
}

String getUtcTime(){
  Date d = new Date();
  long current = d.getTime()/1000;
  return String.valueOf(current + 2);
}