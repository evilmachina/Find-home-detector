#include <Wire.h>
#include <NewSoftSerial.h>
#include <TinyGPS.h>

#define compassAddress  0x32 >> 1 
int slaveAddress;             // This is calculated in the setup() function

byte compassResponseBytes[6];                        // This will hold the raw data from the sensor

int heading = 0;  
int tilt = 0;     
int roll = 0;                    

int i = 0;
int recievedData = 0;
const int gpsPower = 4;
const int compassPower = 5;
const int north = 10;
const int northeast = 11;
const int east = 12;
const int southeast = 13;
const int southwest = 6;
const int west = 7;
const int northwest = 8;

const float destinationLat = 55.597261;
const float destinationLon = 12.979427;

float curentLat, curentLon;
int directionToDestination = 0;

boolean northOn = false;
boolean northeastOn = false;
boolean eastOn = false;
boolean southeastOn = false;
boolean southwestOn = false;
boolean westOn = false;
boolean northwestOn = false;
int realNorth = 0;
int notificationDirection = 0;
TinyGPS gps;
NewSoftSerial nss(3, 2);

void gpsdump(TinyGPS &gps);
bool feedgps();
void printFloat(double f, int digits = 2);



void setup()
{

 while( millis() < 500) { delay(10); }  // The HMC6343 needs a half second to start from power up

 Wire.begin();
 
 Serial.begin(115200);
 nss.begin(4800);
 
 Serial.println("hej:");
 pinMode(gpsPower, OUTPUT); 
 digitalWrite(gpsPower, HIGH);
 pinMode(compassPower, OUTPUT); 
 digitalWrite(compassPower, HIGH);
 pinMode(north, OUTPUT);
 pinMode(northeast, OUTPUT); 
 pinMode(east, OUTPUT); 
 pinMode(southeast, OUTPUT); 
 pinMode(southwest, OUTPUT); 
 pinMode(west, OUTPUT); 
 pinMode(northwest, OUTPUT); 
 
 
}

void loop()
{

  bool newdata = false;
  unsigned long start = millis();

  while (millis() - start < 500)
  {
    if (feedgps())
      newdata = true;
  }
  
  if (newdata)
  {
    Serial.println("Acquired Data");
    
    unsigned long age;
    gps.f_get_position(&curentLat, &curentLon, &age);
    directionToDestination = calculateDirection(curentLat, curentLon,destinationLat,destinationLon) * 10;
    Serial.print("dir: ");
    Serial.println(directionToDestination);
  }
  
  
  readCompass();
  realNorth = 3600-heading;
  notificationDirection = realNorth + directionToDestination;
  if(notificationDirection > 3600)
  {
     notificationDirection = notificationDirection - 3600;
  }
  showDirection(notificationDirection);
  delay(500);
}

void showDirection(int directionToDestination)
{ 
  northOn = 3350 < directionToDestination || directionToDestination < 250;
  northeastOn = 200 < directionToDestination && directionToDestination < 700;
  eastOn = 650 < directionToDestination && directionToDestination < 1150;
  southeastOn = 1100 < directionToDestination && directionToDestination < 1900;
  southwestOn = 1700 < directionToDestination && directionToDestination < 2500;
  westOn = 2450 < directionToDestination && directionToDestination < 2950;
  northwestOn = 2900 < directionToDestination && directionToDestination < 3350; 
  if(directionToDestination > 3600 || directionToDestination < 0)
  {
	  northOn = true;
	  northeastOn = true;
	  eastOn = true;
	  southeastOn = true;
	  southwestOn = true;
	  westOn = true;
	  northwestOn = true;
  }

  digitalWrite(north, northOn);
  digitalWrite(northeast, northeastOn);
  digitalWrite(east, eastOn);
  digitalWrite(southeast, southeastOn);
  digitalWrite(southwest, southwestOn);
  digitalWrite(west, westOn);
  digitalWrite(northwest, northwestOn);
}

void readCompass() 
{ 
  // step 1: instruct sensor to read echoes 
  Wire.beginTransmission(compassAddress);  // transmit to device
                           // the address specified in the datasheet is 66 (0x42) 
                           // but i2c adressing uses the high 7 bits so it's 33 
  Wire.send(0x50);         // Send a "Post Heading Data" (0x50) command to the HMC6343  
  Wire.endTransmission();  // stop transmitting 
 
  // step 2: wait for readings to happen 
  delay(2);               // datasheet suggests at least 1 ms 
  
  // step 3: request reading from sensor 
  Wire.requestFrom(compassAddress, 6);  // request 6 bytes from slave device #33 
 
  // step 4: receive reading from sensor 
  if(6 <= Wire.available())     // if six bytes were received 
  {
    for(int i = 0; i<6; i++) {
      compassResponseBytes[i] = Wire.receive();
    }
  }
  
  heading = ((int)compassResponseBytes[0]<<8) | ((int)compassResponseBytes[1]);  // heading MSB and LSB
  tilt = (((int)compassResponseBytes[2]<<8) | ((int)compassResponseBytes[3]));  // tilt MSB and LSB
  roll = (((int)compassResponseBytes[4]<<8) | ((int)compassResponseBytes[5]));  // roll MSB and LSB
}

bool feedgps()
{
  while (nss.available())
  { 
    char c = nss.read();
   
    if (gps.encode(c))
    {
      return true;
    }
   
  }
 
  return false;
}

float calculateDirection (float lat1, float long1, float lat2, float long2) {
	// returns initial course in degrees (North=0, West=270) from
	// position 1 to position 2, both specified as signed decimal-degrees
	// latitude and longitude.
  float dlon = radians(long2-long1);
  lat1 = radians(lat1);
  lat2 = radians(lat2);
  float a1 = sin(dlon) * cos(lat2);
  float a2 = sin(lat1) * cos(lat2) * cos(dlon);
  a2 = cos(lat1) * sin(lat2) - a2;
  a2 = atan2(a1, a2);
  if (a2 < 0.0) {
  	a2 += TWO_PI;
  }
  return degrees(a2);
}

 

