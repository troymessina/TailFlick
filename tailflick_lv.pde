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
#include <SoftwareSerial.h>

// this constant won't change:
const int  buttonPin = 2;    // the pin that the pushbutton is attached to
const int ledPin = 12;       // the pin that the LED is attached to
int val = 0;                 // variable for reading the pin status
char msg = ' ';              //variable to hold data from serial

// Variables will change:
int buttonPushCounter = 0;   // counter for the number of button presses
int buttonState = 0;         // current state of the button
int lastButtonState = 0;     // previous state of the button

unsigned long time, LoopStart;
extern volatile unsigned long timer0_overflow_count;
unsigned long waitTime = LoopStart + 30000;

void setup() {
  // initialize the button pin as a input:
  pinMode(buttonPin, INPUT);
  // initialize the LED as an output:
  pinMode(ledPin, OUTPUT);
  // initialize serial communication:
  Serial.begin(19200);
  Serial.print("Program Initialized\n");
  //keeps light off
  digitalWrite(ledPin, HIGH);
}


void loop() {
  // read the pushbutton input pin:
  buttonState = digitalRead(buttonPin);
  while (Serial.available()>0){
    msg=Serial.read();
  }

  // compare the buttonState to its previous state
  if (msg=='Y') {
    //turns light on
    digitalWrite(ledPin, LOW);
    if (buttonState != lastButtonState) {
      if (buttonState == HIGH) {
        digitalWrite(ledPin, LOW);
        LoopStart = millis();
        msg = 'Y';
        } 
    
        else {
          digitalWrite(ledPin, HIGH);
          time = millis() - LoopStart;
          //prints time since program started
          msg='N';
          //Serial.println(time/1000.);
          Serial.println("flick");         
        }
    }  

     // save the current state as the last state, 
     //for next time through the loop
    lastButtonState = buttonState;
    
  }
  else {
  }      // if message is anything other than Y do nothing
  
}
