/*
  Dette program  er skrevet af gruppe 580 på Aalborg Universitet på
  produkt og designpsykologi femte semester 2022.

  Programmet er baseret på kode af Michal Rinott, Scott Fitzgerald(2013) og John Bennett (2017)

  Programmet skaber en forbindelse til Wi-Fi og modtager 5 værdier som styrer 5 servomotorer.

  Denne del af koden skal uploades til en ESP32-C3-Devkit og kan kun bruges til at styre:
  Servo Nr. 3 (albuen)

  ESP32-C3 har 'kun' fire timere og det er bleven konkluderet af gruppen at en af disse timere
  bruges af ESP'en og en bruges af Wi-Fi forbindelsen. Altså kan ESP'en kun sende to PWM signaler af gangen.
  Derfor bruges tre ESP32-C3 til at styre de i alt fem servomotorer.
  Koden er identisk pånær port navnet og hvilke værdier af dataArray[] der sendes til motorene.

  Under test blev det opserveret af Serial.Print tog meget af ESP32'ens kraft og derfor printes der aldrig noget mens en motor kører.

  Kommentarene er skrevet på dansk
*/

// Der bruges et ESP32 servo bibliotek samt et Wi-Fi bibliotek
#include "WiFi.h";
#include <ESP32Servo.h>
// Laver et servo objekt som kan controllere en servo motor
Servo Base;
Servo Shoulder;

// Følgende PWM GPIO pins kan bruges på ESP32-C3: 02 og 04. (andre pins kan sikkert også virke men ikke samtidig)
int BasePin = 04;
int ShoulderPin = 02;

float BaseVal = 90; // værdi som Base servo motoren får tilsendt
float ShoulderVal = 90;  // værdi som Shoulder servo motoren får tilsendt


//Smoothing
float BaseGoal = 90;
float ShoulderGoal = 90;
float diff = 0;
unsigned long previousMillis = 0UL;
unsigned long interval = 20UL;


// Brug WiFiClient til at lave TCP forbindelser
const char* ssid = "dlink"; // Navnet på Wi-Fi'en
const char* password = "";  // "" betyder at der ikke er noget kodeord
WiFiClient client;
const uint16_t port = 5205;//port navn der skal stemme overens med port navn på serveren
const char * host1 = "192.168.0.105"; //host navn den skal forbinde til - skal stemme overens med IP'en hos serveren (den computer processing er tilsluttet)

byte values_sent = 5; //antallet af værdier der sendes fra processing
int dataArray[5]; //arrayet der holder på alle værdierne fra processing


void setup()
{
  Serial.begin(9600);
  Base.attach(BasePin, 600, 2500);
  Shoulder.attach(ShoulderPin, 600, 2500);
  // Fortæller ESP32-C3 at Servo objekterne sidder på pin 02 og pin 04
  // og at denne har en minimum PWM værdi på 500 og en maks på 2400 mikrosekunder

  //Wi-Fi:
  WiFi.begin(ssid, password); //WiFi-begin indeholder bare navn og password på Wi-Fi
  Serial.print("'Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) //mens at der er en forbindelse..
  {
    Serial.print(".");
    delay(500);
  }

  Serial.println("\nConnected to the WiFi network");
  Serial.print("IP adress: ");
  Serial.println(WiFi.localIP()); //printer ip adressen for denne klient


}

void loop() {
  if (!client.connected()) //hvis der IKKE er en forbindelse..
  {
    Base.write(BaseVal);        //Sender PWM signal
    Shoulder.write(ShoulderVal);//Sender PWM signal
    Serial.print("Connecting to ");
    Serial.println(host1);
    client.connect(host1, port); //den prøver at forbinde igen
  } else { //hvis der ER en forbindelse..

    if (client.available()) //hvis der bliver sendt noget..
    {
      for (int values_sent = 0; values_sent < 5; values_sent++) {
        //for loop der bruges til at læse alle værdier sendt (de sendes i rækkefølge fra 0 til values_sent fra processing)
        dataArray[values_sent] = client.read();
        //læser hver værdi

        if (dataArray[values_sent] == -1) { //den her bruges til at fjerne støj (støjen i det her tilfælde er værdier på -1)
          dataArray[values_sent] = 0;
          //pladsen sættes til 0
          values_sent = values_sent - 1;
          //loopet går et skridt tilbage og prøver igen
        }
      }

    }

    //Sender de specifikke værdi fra dataArray[] til servomotorene
    BaseGoal = dataArray[0];
    ShoulderGoal = dataArray[1];

    //Flip because motors are mounted in reverse apparently
    BaseGoal = map(BaseGoal, 0, 180, 180, 0);
    ShoulderGoal = map(ShoulderGoal, 0, 180, 180, 0);

    //smoothing
    unsigned long currentMillis = millis();
    if (currentMillis - previousMillis > interval)
    {
      /* The Arduino executes this code once every second
         (interval = 1000 (ms) = 1 second). */
      //Smooth base
      diff = (BaseGoal - BaseVal) * 0.05; //if basegoal is over baseval the difference is positive
      BaseVal = BaseVal + diff;

      //smooth shoulder
      diff = (ShoulderGoal - ShoulderVal) * 0.05; //if shouldergoal is under shoulderval the difference is negative
      ShoulderVal = ShoulderVal + diff;
      // Don't forget to update the previousMillis value
      previousMillis = currentMillis;
    }

    Base.write(BaseVal);        //Sender PWM signal
    Shoulder.write(ShoulderVal);//Sender PWM signal

  }
}
