class InvKin {
  float L1;
  float L2;
  float[] q=new float[3];

  float q1=90;
  float q2=90;
  float q3=90;
  float hyp1;
  float hyp2;
  float beta;
  float gamma;

  InvKin(float L1, float L2) {
    float scale=1;
    this.L1=L1*scale;
    this.L2=L2*scale;
  }

  float[] CalculateAngles(float x, float y, float z) {
    y=map(y, 500, 0, 0, 500); //Leapmotions y is flipped so 0 is at top and 500 is at bottom so we flip it back
    Inversekinematics(x, y, z);
    q[0]=this.q1;
    q[1]=this.q2;
    q[2]=this.q3;
    //println("Angles:\n"+degrees(q[0])+"\n"+degrees(q[1])+"\n"+degrees(q[2])+"\n");
    return this.q;
  }
  void Inversekinematics( float x, float y, float z) {
    //println("x:"+int(x)+" y:"+int(y)+" z:"+int(z));

    if (x==500)x=501;  //Hvis x=500 er der division med 0
    if (x>500) {
      x=x-500;
      this.q1=atan(z/(x));
    } else {
      x=500-x;
      this.q1=atan(z/(x));
      this.q1=radians(180)-this.q1;
    }

    this.hyp1=sqrt((x*x)+(z*z));
    this.hyp2=sqrt(this.hyp1*this.hyp1+y*y);

    float temp=(this.L1*this.L1+this.hyp2*this.hyp2-this.L2*this.L2)/(2*this.L1*this.hyp2);
    this.beta=acos(temp);
    this.gamma=atan(y/this.hyp2);
    this.q2=this.beta+this.gamma;
    this.q3=acos((this.L1*this.L1+this.L2*this.L2-this.hyp2*this.hyp2)/(2*this.L1*this.L2));
    //println(temp);
    //println(" q1:"+degrees(this.q1)+" q2:"+degrees(this.q2)+" q3:"+degrees(this.q3)); //"beta:"+beta+" gamma:"+gamma+" hyp:"+hyp1+" hyp2:"+hyp2+
  }
}
