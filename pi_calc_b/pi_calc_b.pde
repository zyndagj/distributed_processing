import processing.net.*;
import java.net.*;

Server me;
Client partner;
String partnerIP = "localhost";
int port = 1111;

float x, y, d;
int radius;
int canvSize = 700;
color fillC;
float inCircle = 0;
float count = 0;

void setup() {
  size(canvSize, canvSize);
  radius = canvSize/2;
  background(0);
  noStroke();
  // Start server
  me = new Server(this, port);
  connectToPartner(this, 1234);
}

void connectToPartner(PApplet parent, int pPort) {
  while(!pingable(partnerIP, pPort)) {
    delay(500);
  }
  partner = new Client(parent, partnerIP, pPort);
}

void draw() {
  x = random(canvSize);
  y = random(canvSize);
  d = dist(radius,radius,x,y);
  if(d < radius) {
    inCircle++;
    fillC = #448AFF; //blue 
  } else {
    fillC = #FFC107; //amber
  }
  fill(fillC, 30);
  ellipse(x,y,50,50);
  count++;
  if( count % 500 == 0 ) {
    println("After",count,"loops");
    println("Alone: PI ~",nf(4.0*inCircle/count,1,6),(char)177,
      nf(1.0/sqrt(count),1,6));
    if(pingable(partnerIP,1234)) {
      partner.write(nf(inCircle,0,0)+","+nf(count,0,0));
      getMessage();
    } 
  }
}

void getMessage() {
  Client fromPartner = me.available();
  while(fromPartner == null){
    delay(500);
    fromPartner = me.available(); 
  }
  String partnerMessage = fromPartner.readString();
  String[] nums = partnerMessage.split(",");
  float pIN = float(nums[0]);
  float pCount = float(nums[1]);
  println("Combined: PI ~",nf(4.0*(inCircle+pIN)/(count+pCount),1,6),(char)177,
        nf(1.0/sqrt(count+pCount),1,6));
}

boolean pingable(String ip, int port) {
  // Determines if a server is reachable
  // by opening a socket connection.
  try {
    Socket soc = new Socket(ip, port);
    //soc.close();
    return true; 
  } catch(UnknownHostException e) {
    return false;
  } catch(IOException e) {
    return false;
  }
}
