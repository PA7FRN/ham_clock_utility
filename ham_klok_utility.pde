/**
 * SyncArduinoClock. 
 *
 * portIndex must be set to the port connected to the Arduino
 * 
 * The current time is sent in response to request message from Arduino 
 * or by clicking the display window 
 *
 * The time message is 11 ASCII text characters; a header (the letter 'T')
 * followed by the ten digit system time (unix time)
 */
 

import processing.serial.*;
import java.util.Date;
import controlP5.*;

ControlP5 cp5;

public static final short portIndex = 0;  // select the com port, 0 is the first port
public static final String TIME_HEADER = "T"; //header for arduino serial time message 
//public static final char LF = 10;     // ASCII linefeed
//public static final char CR = 13;     // ASCII linefeed
Serial myPort;     // Create object from Serial class
int txStep = 0;
long taskTimer = 0;
long taskTime = 1500;

void setup() {  
  size(400, 400);

 // PFont font = createFont("arial",20);

  cp5 = new ControlP5(this);
  
  cp5.addTextfield("textValue")
     .setPosition(20,170)
     .setSize(200,40)
     .setFont(createFont("arial",20))
     .setAutoClear(false)
     ;

                   cp5.addBang("clear")
     .setPosition(240,170)
     .setSize(80,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;    

  println(Serial.list());
  println(" Connecting to -> " + Serial.list()[portIndex]);
  myPort = new Serial(this,Serial.list()[portIndex], 9600);
  println(getTimeNow());


  taskTimer = millis();
}

void draw() {
  millis();
  textSize(20);
  textAlign(CENTER);
  fill(0);
  text("Click to send\nTime Sync", 0, 75, 200, 175);
  rxMessage();

  if (txStep < 5) {
    long currentMillis = millis();
    if (currentMillis - taskTimer >= taskTime) {
      taskTimer = currentMillis;
      switch (txStep) {
        case 2:
          sendMessage( TIME_HEADER, getTimeNow());
          break;
        case 3:
          sendMessage( "call", "PA7FRN"); 
          break;
        case 4:
          sendMessage( "df"  , "ddMMMyyyy");
          break;
      }
      txStep++;
    }
  }
}

void mousePressed() {
  if (txStep > 4) {
    txStep = 0;
  }
}

void rxMessage() {
  if ( myPort.available() > 0) {  // If data is available,
    char val = char(myPort.read());         // read it and store it in val
    print(val); 
  }  
}

void sendMessage(String cmd, String par) {
  myPort.write(cmd + " " + par);
//  myPort.write('\n');  
}

String getTimeNow(){
  // java time is in ms, we want secs    
  Date d = new Date();
  long current = d.getTime()/1000;
  return String.valueOf(current);
}