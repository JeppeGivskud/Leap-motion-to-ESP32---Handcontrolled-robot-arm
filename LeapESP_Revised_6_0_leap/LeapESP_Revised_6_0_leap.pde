  /*MÅL:
 
 Lav en visualisering af basen igen
 skaler testgraph noget bedre
 Gør sådan at length giver mening
 test om lortet virker
 
 */
import de.voidplus.leapmotion.*;
import processing.net.*;

LeapMotion leap;

//Group 580 addition:
//Server:
Server myServer; //inistialisere myServer som en server
Server myServer2; //inistialisere myServer som en server
Server myServer3; //inistialisere myServer som en server
String incoming="no connection";//tror ikke den gør noget
int sendData;//variabel brugt til at sende dataet

int values_amount = 5;//antallet af variabler som skal sendes til esp
float[] serielarray = new float[values_amount];
int[] values = new int[values_amount];//laver et array med de variabler som skal sendes

//Inverse kinematics:
InvKin InvKin;
TestGraph Test;
float l1=450, l2=550; //lenght of arms in relation to 1000
float[] inv_kin_angles = new float[3];

//More angles:
float wrist_angle;
float   handPinch=0.5;

PVector handPosition = new PVector(0, 0, 0);

void setup() {
  size(800, 500);
  background(255);
  leap = new LeapMotion(this);

  //Group 580:
  fill(255);
  stroke(255);

  inv_kin_angles[0] = radians(90);
  inv_kin_angles[1] = radians(90);
  inv_kin_angles[2] = radians(90);
  wrist_angle = radians(90);
  handPinch=1;

  InvKin = new InvKin(l1, l2);
  Test= new TestGraph(l1, l2, inv_kin_angles[0], inv_kin_angles[1]);

  //Server:
  myServer = new Server(this, 5204); //laver en server med porten 5204
  myServer2 = new Server(this, 5205); //laver en server med porten 5205
  myServer3 = new Server(this, 5206); //laver en server med porten 5206
  println(Server.ip()); //skriver ip adressen ud så man kan se den
}

void draw() {
  background(255);
  for (Hand hand : leap.getHands ()) {
    // 2. Hand
    handPosition       = hand.getPosition();
    handPinch          = hand.getPinchStrength();
  }

  if (handPosition.x<2000 && handPosition.y<1000 &&handPosition.y>-1000) {
    handPosition.x=map(handPosition.x, 0, 1000, -500, 1500);
    handPosition.y=map(handPosition.y, 0, 500, -500, 1500);
    //AAU group 580 Addition:
  }
  goalpositionOverwrite();

  textAlign(LEFT);
  int flyt=-100;
  text("x: "+int(handPosition.x), width/2, height/2-100+flyt);
  text("y: "+int(handPosition.y), width/2, height/2-80+flyt);
  text("z: "+int(handPosition.z), width/2, height/2-60+flyt);

  //Inverse kinematics - finder 3 vinkler - base, skulder, albue
  if (checkBoundaries(handPosition)) {
    inv_kin_angles=InvKin.CalculateAngles(handPosition.x, handPosition.y, handPosition.z*10);
  }
  //Wrist
  wrist_angle=Wrist(inv_kin_angles[1], inv_kin_angles[2]); //finder vinklen på håndledet hvis den skal være horizontal hvor 0º peger imod M2

  //Pinch
  if (handPinch<1&&handPinch>0) {
    handPinch=map(handPinch, 0, 1, 0, 60);
    handPinch=map(handPinch, 0, 60, 60, 0 );
  }
  //graphoverwrite();
  
  //Testgraphs --> Render arm fra siden
  Test.RenderSide(inv_kin_angles[1], inv_kin_angles[2], wrist_angle);
  Test.RenderTop(inv_kin_angles[0]);
  Test.RenderPinch(handPinch);

  //Angles for arduino
  serielarray[0]=degrees(inv_kin_angles[0]); //Base
  serielarray[1]=degrees(inv_kin_angles[1]); //Shoulder
  serielarray[2]=degrees(inv_kin_angles[2]); //Elbow
  serielarray[3]=(wrist_angle);              //Wrist
  serielarray[4]=(handPinch);                //Pinch



  //Changes for motors:
  //serielarray[1]=map(serielarray[1], 0, 180, 180, 0);
  //serielarray[2]=map(serielarray[2], 0, 180, 180, 0); //invert elbow angle
  //serielarray[3]=serielarray[3]-90;                   //0º vender vinkelret ned fra M2 (hvis du forstår
  //println(serielarray);
  //println(values);

  //angleOverwrite(); //Hvis vinkler skal testes individuelt


  //OVERWRITE PINCH VALUE
  //serielarray[4]=map(mouseX,0,width,30,130);

  //Seriel:
  Intarray(); //ændrer serielarray til et intarray
  for (int i = 0; i < values.length; i++) { //for loop der sender alle værdierne til esp32 i rækkefølge
    println("v: "+i+"="+values[i]);
    myServer.write(values[i]);
    myServer2.write(values[i]);
    myServer3.write(values[i]);
  }

  //Modtag data
  Client myclient = myServer.available(); //bliver brugt til at modtage data fra esp
  if (myclient != null) {
    incoming = myclient.readString(); //læser det data som bliver sendt til processing fra esp32
  }
}

void Intarray() {
  for (int i=0; i<serielarray.length; i++) {
    values[i]=int(serielarray[i]);
  }
}

float Wrist(float shoulder, float elbow) { //finder vinklen på håndledet hvis den skal være horizontal hvor 0º peger imod M2
  wrist_angle=360-(degrees(shoulder+elbow));
  wrist_angle+=-90;
  return wrist_angle;
}

void serverEvent(Server someServer, Client someClient) {
  println("We have a new client: " + someClient.ip());
  //ved ikke hvad det her gør, så niks pille!
}

PVector manualControl = new PVector(500, 0, 50); //Starter med 90,90,90 grader
void goalpositionOverwrite() {
  manualControl.x=map(mouseX, 0, width, -500, 1500);
  manualControl.z=map(mouseY, 0, height, 100, 0);

  int change=10;
  if (key=='j') {
    manualControl.y=manualControl.y-change;
  }
  if (key=='l') {
    manualControl.y=manualControl.y+change;
  }
  key='i'; //resets key
  handPosition.set(manualControl.x, manualControl.y, manualControl.z);
  textSize(20);
  //text(handPosition.x, 40, 20);
  //text(handPosition.y, 40, 40);
  //text(handPosition.z, 40, 60);
}

void angleOverwrite() {
  //Angles for arduino
  float Testval=map(mouseX, 0, width, 0, 180);
  textSize(50);
  text(Testval, width/2, height/2-100);

  serielarray[0]=90;    //Base
  serielarray[1]=Testval;    //Shoulder
  serielarray[2]=90;     //Elbow
  serielarray[3]=90;     //Wrist
  serielarray[4]=50;      //Pinch
}
void graphoverwrite() {
  //Angles for arduino
  float Testval=map(mouseX, 0, width, 0, 180);
  textSize(50);
  text(Testval, width/2, height/2-100);
  //Testval=radians(Testval);
  float retvinklet=radians(90);
  inv_kin_angles[0]=retvinklet;    //Base
  inv_kin_angles[1]=retvinklet;    //Shoulder
  inv_kin_angles[2]=retvinklet;     //Elbow
  wrist_angle=90;     //Wrist
  handPinch=Testval;      //Pinch
}
boolean checkBoundaries(PVector Pos) {
  if ( (Pos.x>-400  &&  Pos.x<1400)
    && (Pos.y<1000  &&  Pos.y>-400)
    && (Pos.z<100   &&  Pos.z>10)) {
    return true;
  } else return false;
}
