import processing.net.*;

Client cOther;
Server sMe;
int[] ports = {2342, 3223};

float radius = 25; // radius
float diam = radius*2;
float[] ball = {25,25,2,3}; // {x,y,vx,vy}

boolean hasBall = false;

boolean connected = false; 

void setup() {
  size(500, 500);
  fill(0);
  sMe = new Server(this,ports[1]);
  while ( ! connected ) {
      cOther = new Client(this, "127.0.0.1", ports[0]);
      if (cOther.active()) {
        connected = true;
      }
  }
  background(255);
}

void draw() {
  if (hasBall) {
    background(255);
    ellipse(ball[0],ball[1],diam,diam);
    ball[0] += ball[2];
    ball[1] += ball[3];
    if ( ball[0] < 0) {
      String[] sList = nf(ball, 0, 0);
      String outS = join(sList,",");
      cOther.write(outS);
      hasBall = false;
      background(255);
    }
    if ( ball[0] > width-radius ) {
      ball[2] *= -1;
    }
    if ( ball[1] > height-radius || ball[1] < radius ) {
      ball[3] *= -1;
    }
  } else {
    Client fClient = sMe.available();
    if ( fClient != null ) {
      println("Got message");
      String bString = fClient.readString();
      println(bString);
      String[] bList = bString.split(",");
      for (int i = 0; i < 4; i++) {
        ball[i] = float(bList[i]);
        println(float(bList[i]), ball[i]);
      }
      ball[0]=0;
      hasBall = true;
    }
  }
}
