class TestGraph {
  float l1, l2, q0, q1, q2, q3;
  float x1=0, y1=0, x2=0, y2=0, x3=0, y3=0, wristx, wristy;

  //Til basevisualisering - BRUGES IKKE
  float q1Length, q2Length;

  TestGraph(float l1, float l2, float q1, float q2) {
    this.l1=l1;
    this.l2=l2;
    this.q1=q1;
    this.q2=q2;
  }
  void RenderPinch(float Pinch) {
    Pinch=map(Pinch, 60, 0, 90, 0);
    if (Pinch<92&&Pinch>-2) {
      float Length= 80;
      float baseX=width-Length;
      float baseY=height-Length;
      float xForskudt = sin(radians(Pinch))*Length;
      float yForskudt = cos(radians(Pinch))*Length;
      //println(xForskudt);
      //tan=m/h <=> m=tan*h <=> h=m/tan
      line(baseX, baseY, baseX+xForskudt, baseY-yForskudt);
      line(baseX, baseY, baseX-xForskudt, baseY-yForskudt);
      Pinch=map(Pinch, 90, 0, 0, 90);
      textAlign(CENTER);
      text("Pinch:"+int(Pinch)+"º", baseX, baseY+20);
    }
  }
  void RenderTop(float q0) {
    //Renders a top view of the robot arm. Therefore the Y axis is now drawn with X and the X axis is drawn with Z
    float Width=200;
    float StartX=width-Width-4;
    float StartY=0;
    fill(0);
    text("Top-view", StartX+Width/2, StartY+Width+30);
    fill(255);
    square(StartX, StartY, Width);

    float Len = wristx; //længde af armen set fra toppen
    Len = map(Len, 0, 800, 0, 200);
    float GoalDeltaX = cos((q0))*Len;
    float GoalDeltaY = sin((q0))*Len;

    float LenElbow = x2; //længde af armen set fra toppen
    LenElbow = map(LenElbow, 0, 800, 0, 200);
    float ElbowX = cos((q0))*LenElbow;
    float ElbowY = sin((q0))*LenElbow;

    float AnchorbaseX=StartX+Width/2;
    float AnchorbaseY=StartY+Width;

    GoalDeltaX=GoalDeltaX+AnchorbaseX;
    GoalDeltaY=-GoalDeltaY+AnchorbaseY;
    ElbowX=ElbowX+AnchorbaseX;
    ElbowY=-ElbowY+AnchorbaseY;

    stroke(0, 150, 0);
    line(AnchorbaseX, AnchorbaseY, ElbowX, ElbowY);
    circle(AnchorbaseX, AnchorbaseY, 20);
    circle(ElbowX, ElbowY, 15);

    stroke(0, 210, 0);
    line(ElbowX, ElbowY, GoalDeltaX, GoalDeltaY);
    circle(GoalDeltaX, GoalDeltaY, 20);


    fill(0);
    text(int(degrees(q0))+"º", AnchorbaseX+20, AnchorbaseY+5);
    //text("x:"+handPosition.x+" y:"+handPosition.y+" z:"+handPosition.z*10, GoalDeltaX+20, GoalDeltaY+5);
    text(int(handPosition.x)+" ,"+int(handPosition.y)+" ,"+int(handPosition.z*10), GoalDeltaX+20, GoalDeltaY+5);
  }

  void RenderSide(float q1, float q2, float q3) {
    this.q1=q1;
    this.q2=q2;
    this.q3=q3;

    x1=0;
    y1=0;
    x2=cos(this.q1)*l1;
    y2=sin(this.q1)*l1;

    float tempQ=q1-(radians(180)-q2); //skal tegnes anderledes i processing end i virkeligheden
    x3=x2  +  cos(tempQ)*l2;
    y3=y2  +  sin(tempQ)*l2;

    //println("x2: "+x2+" y2: "+y2+" x3: "+x3+" y3: "+y3);

    Scale_Drawing();
    stroke(0, 200, 0);
    strokeWeight(10);
    Draw_Lines(x1, y1, x2, y2, x3, y3);
    textSize(20);
    text("Side-view:", 50, 100);
  }

  void Scale_Drawing() {
    float Scaling=0.7;
    y1=(y1*Scaling);
    y2=(y2*Scaling);
    y3=(y3*Scaling);
    x1=(x1*Scaling);
    x2=(x2*Scaling);
    x3=(x3*Scaling);

    float wrist_length=50;
    wristx=x3+wrist_length;
    wristy=y3;
  }

  void Draw_Lines(float x1, float y1, float x2, float y2, float x3, float y3) {
    y1=(y1*-1+height);
    y2=(y2*-1+height);
    y3=(y3*-1+height);
    wristy=(wristy*-1+height);

    line(x1, y1, x2, y2);
    line(x2, y2, x3, y3);
    line(x3, y3, wristx, wristy);

    int size=5;
    circle(x1, y1, size);
    circle(x2, y2, size);
    circle(x3, y3, size);
    circle(wristx, wristy, size);

    //text
    text(int(degrees(this.q1))+"º", x1+20, y1-10);
    text(int(degrees(this.q2))+"º", x2+5, y2-15);
    text(int(this.q3)+"º", x3+5, y3+25);
  }
}
