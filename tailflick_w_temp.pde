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
#include <math.h>
#include <SoftwareSerial.h>

// this constant won't change:
const int  sensePin = 2;    // the pin that the phototransistor is attached to
const int relayPin = 12;       // the pin that the relay is attached to
int val = 0;                 // variable for reading the pin status
char msg = ' ';              //variable to hold data from serial

// Variables will change:
int senseState = 0;         // current state of the phototransistor
int lastsenseState = 0;     // previous state of the phototransistor

unsigned long time, LoopStart;
extern volatile unsigned long timer0_overflow_count;
unsigned long waitTime = LoopStart + 30000;

/* Thermistor
 * Inputs ADC Value from Thermistor and outputs Temperature in Celsius
 *  requires: include <math.h>
 * Utilizes the Steinhart-Hart Thermistor Equation:
 * Schematic:
 *   [Ground] -- [10k-pad-resistor] -- | -- [thermistor] --[Vcc (5 or 3.3v)]
 *                                     |
 *                                Analog Pin 1/2
 *
 * In case it isn't obvious (as it wasn't to me until I thought about it), the analog ports
 * measure a 10-bit digitized voltage between 0v -> Vcc which for an Arduino is a nominal 5V
 *
 * The resistance calculation uses the ratio of the Vcc to the Vpad. This ensures that if there are
 * variations in Vcc they are taken care of in the calculation.
 * Resistance = (Vcc(ADC0)/Vpad(ADC1 or 2) - 1) * Rpad 
*/
double Thermistor(int RawADC1, int RawADC2) {
  
 double Temp, Resistance, Volts, nom_R=9780., dummy;
 Volts = double(RawADC2) / 1024. * 5.; //check the Arduino voltage for adjusting (not yet implemented)
 dummy = double(RawADC2)/double(RawADC1); //Vcc/Vpad
// Resistance = log(10240000/RawADC1 - 10000);
 Resistance = log((dummy - 1.) * nom_R); //This is the actual resistance value since it uses the total Arduino voltage
 //Datasheet data fitted in Igor as T(C) vs. R(ohms)
 Temp = 362.62 - 69.556 * Resistance + 4.3026 * Resistance*Resistance - 0.11392 * Resistance*Resistance*Resistance;
 //Temp = Temp - 273.15;            // Convert Kelvin to Celcius
// Temp = (Temp * 9.0)/ 5.0 + 32.0; // Convert Celcius to Fahrenheit
 return Temp;
}

void setup() {
  // initialize the sense pin as a input:
  pinMode(sensePin, INPUT);
  // initialize the relay pin as an output:
  pinMode(relayPin, OUTPUT);
  // initialize serial communication:
  Serial.begin(9600);
  Serial.print("Program Initialized\n");
  //keeps light off
  digitalWrite(relayPin, HIGH);
}


void loop() {
  // read the sense (phototransistor) input pin:
  senseState = digitalRead(sensePin);
  while (Serial.available()>0){
    msg=Serial.read();
  }

  // compare the senseState to its previous state
  if (msg=='Y') {
    //turns light on
    digitalWrite(relayPin, LOW);
    if(millis() % 1000 > 950){
      Serial.print(Thermistor(analogRead(1), analogRead(0)), 1);
      Serial.print(", ");
      Serial.println(Thermistor(analogRead(2), analogRead(0)), 1);
    }
    if (senseState != lastsenseState) {
      if (senseState == HIGH) { //no light is seen
        digitalWrite(relayPin, LOW); //keep the relay closed for heat lamp on
        LoopStart = millis();
        msg = 'Y';
        } 
    
        else { //the sensor sees light causing pin 2 to be LOW
          digitalWrite(relayPin, HIGH);//switch the relay to high, turning the light off
          time = millis() - LoopStart;
          //prints time since program started
          msg='N';
          //Serial.println(time/1000.);
          //Serial.flush();
          Serial.print("flick");
        }
    }  

     // save the current state as the last state, 
     //for next time through the loop
    lastsenseState = senseState;
    
  }
  else {
  }      // if message is anything other than Y do nothing
  
}
