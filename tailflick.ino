/*
  State change detection (edge detection)
 	
 This program monitors a rodent tail flick and records the 
 time to a file specified by the user
 	
 The circuit:
 * phototransistor that sets pin 2 high when activated
 * connects 5V to an electronic relay when activated
 * the electronic relay controls the heat lamp
 
 created  27 Sep 2010
 modified 26 Oct 2010
 by Aaron Otto

This example code is based on 	
 http://arduino.cc/en/Tutorial/ButtonStateChange
 
 */
//include libraries for reading and writing to the serial port
//#include <SoftwareSerial.h>

// this constant won't change:
const int  sensorPin = 2;    // the pin that the sensor is attached to
const int relayPin = 12;       // the pin that the relay and heat lamp is attached to
char msg = ' ';              //variable to hold data from serial

// Variables will change:
int buttonState = 0;         // current state of the button
int lastButtonState = 1;     // previous state of the button

unsigned long LoopStart;
float dt;

void setup() {
  // initialize the button pin as a input:
  pinMode(sensorPin, INPUT);
  // initialize the LED as an output:
  pinMode(relayPin, OUTPUT);
  // initialize serial communication:
  Serial.begin(9600);
  Serial.print("Program Initialized\n");
  //keeps light off
  digitalWrite(relayPin, HIGH);
}


void loop() {
  // read the pushbutton input pin:
  buttonState = digitalRead(sensorPin);
  while (Serial.available()>0){
    msg=Serial.read();
  }

  if (msg=='Y') {
    //turns light on
    digitalWrite(relayPin, LOW);
    if (buttonState != lastButtonState) {//compare the buttonState to its previous state. No sense wasting time if it hasn't changed.
      if (buttonState == HIGH) { //no light is seen
        digitalWrite(relayPin, LOW); //keep the relay closed for heat lamp on
        LoopStart = millis(); //get the initial time on the millisecond timer
        msg = 'Y'; //keep the message set to continue running
        }
        else { //the sensor sees light, turning pin 2 LOW
          digitalWrite(relayPin, HIGH); //turn the heat lamp off
          dt = (millis() - LoopStart)/1000.; //record the time passed since the initial time
          //prints time since program started
          msg='N';
          Serial.println(dt);          
        }
    }  

     // save the current state as the last state, 
     //for next time through the loop
    lastButtonState = buttonState;
    
  }
  else {
  }      // if message is anything other than Y do nothing
  
}
