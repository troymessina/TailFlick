#include <math.h>

double Thermistor(int RawADC1, int RawADC2) {
  
 double Temp, Resistance, Volts, nom_R=9780., dummy;
 Volts = double(RawADC2) / 1024. * 5.; //check the Arduino voltage for adjusting (not yet implemented)
 dummy = double(RawADC2)/double(RawADC1);
// Resistance = log(10240000/RawADC1 - 10000);
 Resistance = log((dummy - 1.) * nom_R); //This is the actual resistance value since it uses the total Arduino voltage
   
 //Datasheet data fitted in Igor as T(C) vs. R(ohms)
 Temp = 362.62 - 69.556 * Resistance + 4.3026 * Resistance*Resistance - 0.11392 * Resistance*Resistance*Resistance;
 //Temp = Temp - 273.15;            // Convert Kelvin to Celcius
// Temp = (Temp * 9.0)/ 5.0 + 32.0; // Convert Celcius to Fahrenheit
 return Temp;
}

void setup() {
 Serial.begin(9600);
//Serial.print("Program Initialized\n");
}


void loop() {
  Serial.println("Thermistor 1");
  Serial.println(Thermistor(analogRead(1), analogRead(0)));
  Serial.println("Thermistor 2");
  Serial.println(Thermistor(analogRead(2), analogRead(0)));// display Fahrenheit
 delay(5000);
}
