// Launches a webcam and searches for QR Codes, prints their message and draws their outline
// Edited by Victor Permild for Situating Interactions 2020, ITU Copenhagen

import java.util.*;
// for Capture
import processing.video.*;
// for qrDetection
import boofcv.processing.*;
import boofcv.struct.image.*;
import boofcv.alg.fiducial.qrcode.QrCode;
// for saturation;
import milchreis.imageprocessing.*;
//for Polygon2D_F64 points and shapes
import georegression.struct.shapes.Polygon2D_F64;
import georegression.struct.point.Point2D_F64;

Capture cam;
SimpleQrCode detector;
// variable used to find contours
SimpleGray gray;
PImage imgContour;
PImage imgBlobs;
PImage input;
PImage test;
PImage saturated;
PShape ps;
PGraphics pg;
PGraphics bg;
PGraphics cammi;
ArrayList<PGraphics> graphics = new ArrayList<PGraphics>();
int layerLimit;
int debug = 0;
String[] debugText = {""};
StringDict debugInventory;

void setup() {
  size(1280, 480);
  /* size(640, 480, P3D); */
  debugInventory = new StringDict();
  debug = 1;
  /* size(1280, 480); */
  // Open up the camera so that it has a video feed to process
  initializeCamera(640, 480);
  graphics.add(createGraphics(640,480));
  /* pg = createGraphics(640, 480); */
  bg = createGraphics(640, 480);
  /* cammi = createGraphics(640, 480); */

  if (debug > 0) {
    surface.setSize(cam.width*2, cam.height);
  } else {
    surface.setSize(cam.width, cam.height);
  }

  detector = Boof.detectQR();
}

void draw() {
  graphics.get(0).beginDraw();

  /* pg.beginDraw(); */
  if (cam.available() == true) {
    cam.read();

    List<QrCode> found = detector.detect(cam);
    if (found.size() == 0) {
      if (graphics.size() > 0) {
        for (int i = 0; i < graphics.size() - 1; i++) {
          graphics.remove(i + 1);
        };
      }
    }
    layerLimit = found.size();
    /* gray = Boof.gray(cam,ImageDataType.F32); */
    /* saturated = gray.convert(); */
    saturated = Saturation.apply(cam, 0.05);
    graphics.get(0).image(saturated, 0, 0);
    /* float intensity = map(mouseX, 0, width, 0.0f, 2.0f); */
    /* println("intensity: " + intensity); */
    /* pg.image(saturated, 0, 0); */
    /* image(saturated, 0, 0); */
    /* image(saturated, 0, 0); */
    /* image(cam, 0, 0); */


    Point2D_F64[] bounds = new Point2D_F64[4];

    /* testDraw(); */
    /* testPshape(); */
    // The QR codes being tested have a height and width of 42
    for ( QrCode qr : found ) {
      if (graphics.size() < layerLimit + 1) {
        graphics.add(createGraphics(640,480));
      }
      if (debug > 0) {
        fill(255, 255, 255);
        /* stroke(0); */
        /* strokeWeight(10); */

        rect(cam.width, 0, cam.width, cam.height);
      }
      /* println("message             "+qr.message); */
      /* println("qr.bounds.size():    " +  qr.bounds.size()); */

      /* image(cam, 0, 0); */
      /* texture(cam); */
      for ( int i = 0; i < qr.bounds.size(); i++ ) {
        /* println("qr.bounds.get(i):      " + qr.bounds.get(i)); */
        bounds[i] = qr.bounds.get(i);

      }

      /* Point2D_F64[] newBounds = expandBoundsByPerspective(42, 90, 240, bounds); */
      /* Point2D_F64[] newBounds = expandifier(42, 82, 230, bounds); */
      /* Point2D_F64[] newBounds = expandFromQR(42, 82, 230, bounds); */
      /* Point2D_F64[] newBounds = createSquare(bounds, 42, 82, 230); */
      drawGraphics(bounds, 42, 90, 240);
      /* drawVertices(bounds, newBounds); */
      /* drawNewPoints(newBounds); */
      /* saturator(newBounds); */

      if (debug > 0) {
        debugPrint(8);
        /* printPoints(bounds, "bounds"); */
        /* printPoints(newBounds, "newBounds"); */
        colorPoints(bounds);
        /* colorPoints(newBounds); */
      }
      if (debug > 1) {
        String printpoints = "";
        for (int j = 0; j < bounds.length; j++) {
          printpoints = printpoints + bounds[j].toString();
        };
        debugInventory.set("bounds: ", printpoints);
        /* println("bounds:"); */
        /* println(bounds); */
      }
      noStroke();
    }

  }

  /* pg.endDraw(); */

  /* image(pg, 0, 0); */
  graphics.get(0).endDraw();
  for (int i = 0; i < graphics.size(); i++) {
    image(graphics.get(i), 0, 0);
  };
  /* println("graphics: " + graphics.size()); */
  /* image(graphics.get(0), 0, 0); */
}

Point2D_F64 getCenter(Point2D_F64[] points){
  Point2D_F64 a = points[0];
  Point2D_F64 b = points[1];
  Point2D_F64 c = points[2];
  Point2D_F64 d = points[3];
  float aToB = distanceBetweenTwoPoints(a, b);
  float dToA = distanceBetweenTwoPoints(d, a);
  return a;
}

float distanceBetweenTwoPoints(Point2D_F64 a, Point2D_F64 b) {
  float x1 = (float)a.getX();
  float y1 = (float)a.getY();
  float x2 = (float)b.getX();
  float y2 = (float)b.getY();
  float distance = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
  return distance;
}

void printPoints(Point2D_F64[] points, String name) {
  println("----- " + name + " -----");
  Point2D_F64 a = points[0];
  Point2D_F64 b = points[1];
  Point2D_F64 c = points[2];
  Point2D_F64 d = points[3];
  println("- a - " + a.toString());
  println("- b - " + b.toString());
  println("- c - " + c.toString());
  println("- d - " + d.toString());
}

void drawGraphics(Point2D_F64[] points, int qrWidth, int rectX, int rectY) {
  Point2D_F64 a = points[0];
  Point2D_F64 b = points[1];
  Point2D_F64 c = points[2];
  Point2D_F64 d = points[3];
  float ratioX = (float)rectX / (float)qrWidth;
  float ratioY = (float)rectY / (float)qrWidth;
  // The distance between to points on the detected QR code
  float qrDist = qrDistance(a, b);
  // The width and height of the rectange can be calculated from the detected distance
  float rectWidth = qrDist * ratioX;
  float rectHeight = qrDist * ratioY;
  // The center point of the QR code
  Point2D_F64 center = centerPoint(points);
  // The angle between the sides a -> b & d -> c
  float angle_one = atanifier(a, b);
  float angle_two = atanifier(d, c);
  // they might differ slightly due to viewing angle, so using the average angle to semi-account for this
  float avr_angle = (angle_one + angle_two) / 2;
  int token = 1;
  /* int token = graphics.size() - 1; */
  graphics.get(token).beginDraw();
  graphics.get(token).image(cam, 0, 0);
  bg.beginDraw();
  bg.noStroke();
  /* bg.quad((float)a.x, (float)a.y, (float)b.x, (float)b.y, (float)c.x, (float)c.y, (float)d.x, (float)d.y); */
  bg.rectMode(CENTER);
  bg.pushMatrix();
  bg.translate((float)center.x, (float)center.y);
  bg.rotate(avr_angle);
  bg.rect(0, 0, rectWidth, rectHeight);
  bg.popMatrix();
  bg.endDraw();
  graphics.get(token).endDraw();
  graphics.get(token).mask(bg);
  bg.clear();

}

float qrDistance(Point2D_F64 a, Point2D_F64 b) {
  float x1 = (float)a.getX();
  float y1 = (float)a.getY();
  float x2 = (float)b.getX();
  float y2 = (float)b.getY();
  float distance = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
  return distance;
}
void testDraw() {
  /* cam.loadPixels(); */
  cammi.beginDraw();
  cammi.image(cam, 0, 0);
  bg.beginDraw();
  /* bg.image(cam, 0, 0); */
  /* pg.fill(255); */
  /* pg.stroke(0); */
  bg.noStroke();
  /* pg.image(cam, 0, 0); */
  bg.quad(50, 50, 150, 50, 384, 200, 76, 245);
  bg.endDraw();
  cammi.endDraw();
  cammi.mask(bg);
  /* pg.endDraw(); */
  /* image(pg, 0, 0); */
}

void drawNewPoints(Point2D_F64[] points) {
  Point2D_F64 a = points[0];
  Point2D_F64 b = points[1];
  Point2D_F64 c = points[2];
  Point2D_F64 d = points[3];
  float aX = (float)a.getX();
  float aY = (float)a.getY();

  float bX = (float)b.getX();
  float bY = (float)b.getY();

  float cX = (float)c.getX();
  float cY = (float)c.getY();

  float dX = (float)d.getX();
  float dY = (float)d.getY();
  pg.camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
  pg.beginCamera();
  pg.quad(aX, aY, bX, bY, cX, cY, dX, dY);
  /* pg.image(cam); */
  pg.endCamera();
}

void drawVertices(Point2D_F64[] bounds, Point2D_F64[] newBounds) {
  // Draw a line around each detected QR Code
  beginShape();

    for ( int i = 0; i < newBounds.length; i++ ) {
      /* Point2D_F64 p = qr.bounds.get(i); */
      Point2D_F64 p = newBounds[i];
      vertex( (int)p.x, (int)p.y );
    }

    // close the loop
    Point2D_F64 p = newBounds[0];

    if (debug > 0) {
      debugPrint(8);
      colorPoints(bounds);
      colorPoints(newBounds);
    }
    /* fill(255, 0, 0); */
    /* if (qr.message.charAt(3) == '1') { */
    /*   text("Warning!", (int)p.x-10, (int)p.y-10); */
    /* } */
    strokeWeight(5);
    stroke(255, 0, 0);
    /* fill(255, 0, 0, 50); */
    vertex( (int)p.x, (int)p.y );

  endShape();

}

void debugPrint(int textsize) {
  /* String dist = "distance: " + floor(distance); */
  /* String newDist = "newDistance: " + floor(newDistance); */
  int start = 260;
  textSize(textsize);
  /* strokeWeight(1); */
  /* stroke(0, 0, 0, 50); */
  fill(255, 255, 255);
  rect(640, 240, 640, 240);
  fill(0, 0, 0);
  String print = "";
  String[] keys = debugInventory.keyArray();
  if (keys.length > 0) {
    for (int i = 0; i < keys.length; i++) {
      /* println("Keys[i]: " + keys[i]); */
      print = keys[i] + ": " + debugInventory.get(keys[i]);
      /* int number = debugInventory.get(key[i]); */
      /* println("number: " + number); */
      /* println("print: " + print); */
      text(print, 642, start);
      start = start + textsize + 2;
    };
  }
  /* text(dist, 660, 400); */
  /* text(newDist, 660, 440); */

}

void addDebugText(String data) {
  debugText = append(debugText, data);
}

void colorPoints(Point2D_F64[] points) {
  float s_width = cam.width;
  Point2D_F64 a = points[0];
  Point2D_F64 b = points[1];
  Point2D_F64 c = points[2];
  Point2D_F64 d = points[3];
  float aX = (float)a.getX() + s_width;
  float aY = (float)a.getY();

  float bX = (float)b.getX() + s_width;
  float bY = (float)b.getY();

  float cX = (float)c.getX() + s_width;
  float cY = (float)c.getY();

  float dX = (float)d.getX() + s_width;
  float dY = (float)d.getY();
  strokeWeight(10);

  /* stroke(0, 0, 200); */
  /* point(aX, aY); */

  textSize(16);
  fill(0, 0, 200);
  text("A", aX, aY);

  /* stroke(200, 0, 0); */
  /* point(bX, bY); */
  fill(200, 0, 0);
  text("B", bX, bY);

  fill(0, 200, 0);
  text("C", cX, cY);

  fill(255, 153, 51);
  text("D", dX, dY);



/*   stroke(0, 200, 0); */
/*   point(cX, cY); */

/*   stroke(255, 255, 0); */
/*   point(dX, dY); */
/*   noStroke(); */
}

Point2D_F64[] expander(int qrWidth, int expandX, int expandY, Point2D_F64[] bounds) {

  return bounds;
}

String[] getDirection(float x1, float y1, float x2, float y2) {
  String[] direction = {"", ""};
  if (x2 > x1) {
    direction[0] = "right";
  } else if (x2 < x1) {
    direction[0] = "left";
  }

  if (y2 > y1) {
    direction[1] = "up";
  } else if (y2 < y1) {
    direction[1] = "down";
  }
 return direction;
}

Point2D_F64[] expandBoundsByPerspective(int qrWidth, int expandX, int expandY, Point2D_F64[] bounds) {
  float ratioX = (float)expandX / (float)qrWidth;
  float ratioY = (float)expandY / (float)qrWidth;
  /* println("ratio: " + ratio); */
  /* println("cam.width: " + cam.width + " cam.height: " + cam.height); */
  Point2D_F64 a = bounds[0];
  Point2D_F64 b = bounds[1];
  Point2D_F64 c = bounds[2];
  Point2D_F64 d = bounds[3];
  double aX = a.getX();
  double aY = a.getY();

  double bX = b.getX();
  double bY = b.getY();

  double cX = c.getX();
  double cY = c.getY();

  double dX = d.getX();
  double dY = d.getY();
  // expand aX & bX
  double abX[] = expander(aX, bX, ratioX, cam.width);
  aX = abX[0];
  bX = abX[1];
  // expand bY & cY
  double bcY[] = expander(bY, cY, ratioY, cam.height);
  bY = bcY[0];
  cY = bcY[1];
  // expand cX & dX
  double cdX[] = expander(cX, dX, ratioX, cam.width);
  cX = cdX[0];
  dX = cdX[1];
  // expand dY & aY
  double daY[] = expander(dY, aY, ratioY, cam.height);
  dY = daY[0];
  aY = daY[1];

  a.setX(aX);
  a.setY(aY);
  b.setX(bX);
  b.setY(bY);
  c.setX(cX);
  c.setY(cY);
  d.setX(dX);
  d.setY(dY);
  Point2D_F64[] newPoints = {a, b, c, d};
  return newPoints;
}

/* Point2D_F64[] expandifier(int qrWidth, int expandX, int expandY, Point2D_F64[] points) { */
  /* if (debug > 1) { */
  /*   String printpoints = ""; */
  /*   for (int i = 0; i < points.length; i++) { */
  /*     printpoints = printpoints + points[i].toString(); */
  /*   }; */
  /*   debugInventory.set("points: ", printpoints); */
  /*   /1* println("points:"); *1/ */
  /*   /1* println(points); *1/ */
  /* } */
  /* float ratioX = (float)expandX / (float)qrWidth; */
  /* float ratioY = (float)expandY / (float)qrWidth; */
  /* Point2D_F64 a = points[0]; */
  /* Point2D_F64 b = points[1]; */
  /* Point2D_F64 c = points[2]; */
  /* Point2D_F64 d = points[3]; */
  /* // extend a -> b & c -> d */
  /* Point2D_F64[] ab = extender(a, b, ratioX); */
  /* Point2D_F64[] cd = extender(c, d, ratioX); */
  /* a = ab[0]; */
  /* b = ab[1]; */
  /* c = cd[0]; */
  /* d = cd[1]; */
  /* // extend a -> d & b -> c */
  /* Point2D_F64[] ad = extender(a, d, ratioY); */
  /* Point2D_F64[] bc = extender(b, c, ratioY); */
  /* a = ad[0]; */
  /* d = ad[1]; */
  /* b = bc[0]; */
  /* c = bc[1]; */
  /* /1* Point2D_F64[] da = extender(d, a, ratioY); *1/ */
  /* /1* Point2D_F64[] cb = extender(c, b, ratioY); *1/ */
  /* /1* d = da[0]; *1/ */
  /* /1* a = da[1]; *1/ */
  /* /1* c = cb[0]; *1/ */
  /* /1* b = cb[1]; *1/ */

  /* // gather extended points and return them */
  /* Point2D_F64[] newPoints = {a, b, c, d}; */
  /* /1* newPoints[0] = a; *1/ */
  /* /1* newPoints[1] = b; *1/ */
  /* /1* newPoints[2] = c; *1/ */
  /* /1* newPoints[3] = d; *1/ */
  /* if (debug > 1) { */
  /*   String printpoints = ""; */
  /*   for (int i = 0; i < newPoints.length; i++) { */
  /*     printpoints = printpoints + newPoints[i].toString(); */
  /*   }; */
  /*   debugInventory.set("newPoints: ", printpoints); */
  /*   /1* debugInventory.set("newPoints:", newPoints.toString()); *1/ */
  /*   /1* println("newPoints:"); *1/ */
  /*   /1* println(newPoints); *1/ */
  /* } */
  /* return newPoints; */
/* } */

/* Point2D_F64[] extender(Point2D_F64 a, Point2D_F64 b, float ratio) { */
/*   float x1 = (float)a.getX(); */
/*   float y1 = (float)a.getY(); */
/*   float x2 = (float)b.getX(); */
/*   float y2 = (float)b.getY(); */
/*   float distance = getDistance(a, b , ratio); */
/*   float angle = atanifier(x1, y1, x2, y2); */
/*   float reverseAngle = checkPi(angle); */
/*   /1* println("angle: " + degrees(angle)); *1/ */
/*   /1* println("reverseAngle: " + degrees(reverseAngle)); *1/ */
/*   Point2D_F64 newB = extendedPoint(x2, y2, angle, distance); */
/*   Point2D_F64 newA = extendedPoint(x1, y1, reverseAngle, distance); */
/*   Point2D_F64[] extensions = new Point2D_F64[2]; */
/*   extensions[0] = newA; */
/*   extensions[1] = newB; */

/*   return extensions; */

/* } */

float checkPi(float angle) {
  angle = angle + PI;
  if (angle > 2*PI) {
    angle = angle - 2*PI;
  } else if (angle < 0) {
    angle = 2*PI - angle;
  }
  return angle;
}

float getDistance(Point2D_F64 a, Point2D_F64 b, float ratio) {
  float x1 = (float)a.getX();
  float y1 = (float)a.getY();
  float x2 = (float)b.getX();
  float y2 = (float)b.getY();
  float distance = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
  /* println("distance: " + distance); */
  float newDistance = (distance * ratio - distance)/2;
  /* println("newDistance: "+ newDistance); */
  if (debug > 2) {
    debugInventory.set("distance", str(floor(distance)));
    debugInventory.set("newDistance", str(floor(newDistance)));

  }
  return newDistance;
}

float atanifier(Point2D_F64 a, Point2D_F64 b) {
  float x1 = (float)a.getX();
  float y1 = (float)a.getY();
  float x2 = (float)b.getX();
  float y2 = (float)b.getY();
  float y = y2 - y1;
  float x = x2 - x1;
  float rad = atan2(y,x);// + HALF_PI;
  return rad;
}

Point2D_F64 extendedPoint(float x, float y, float angle, float distance) {
  double newX = x + distance * sin(angle);
  double newY = y + distance * cos(angle);
  newX = checkEdge(newX, cam.width);
  newY = checkEdge(newY, cam.height);
  Point2D_F64 newP = new Point2D_F64(newX, newY);
  return newP;
}

Point2D_F64[] expandFromQR(int qrWidth, int expandX, int expandY, Point2D_F64[] points) {
  if (debug > 1) {
    String printpoints = "";
    for (int i = 0; i < points.length; i++) {
      printpoints = printpoints + points[i].toString();
    };
    debugInventory.set("points: ", printpoints);
    /* println("points:"); */
    /* println(points); */
  }
  float ratioX = (float)expandX / (float)qrWidth;
  float ratioY = (float)expandY / (float)qrWidth;
  Point2D_F64 a = points[0];
  Point2D_F64 b = points[1];
  Point2D_F64 c = points[2];
  Point2D_F64 d = points[3];
  // distance from point d & a returns the extended distance from ratioY
  float distance_one = getDistance(d, a, ratioY);
  // distance from point a & b returns the extended distance from ratioX
  float distance_two = getDistance(a, b, ratioX);
  // triangulate via the angle from d -> a returns the coordinates to the newA coordinates
  float angle_a = angulator(d, a);
  Point2D_F64 newA = triangulator(a, angle_a, distance_one, distance_two);

  // triangulate via the angle from a -> b returns the coordinates to the newB coordinates
  float angle_b = angulator(a, b);
  Point2D_F64 newB = triangulator(b, angle_b, distance_two, distance_one);

  // triangulate via the angle from d -> a returns the coordinates to the newA coordinates
  float angle_c = angulator(b, c);
  Point2D_F64 newC = triangulator(a, angle_c, distance_one, distance_two);

  // triangulate via the angle from d -> a returns the coordinates to the newA coordinates
  float angle_d = angulator(c, d);
  Point2D_F64 newD = triangulator(d, angle_d, distance_two, distance_one);
  // gather extended points and return them
  Point2D_F64[] newPoints = {newA, newB, newC, newD};
  /* newPoints[0] = a; */
  /* newPoints[1] = b; */
  /* newPoints[2] = c; */
  /* newPoints[3] = d; */
  if (debug > 1) {
    String printpoints = "";
    for (int i = 0; i < newPoints.length; i++) {
      printpoints = printpoints + newPoints[i].toString();
    };
    debugInventory.set("newPoints: ", printpoints);
    /* debugInventory.set("newPoints:", newPoints.toString()); */
    /* println("newPoints:"); */
    /* println(newPoints); */
  }
  return newPoints;
}

float angulator(Point2D_F64 a, Point2D_F64 b) {
  float x1 = (float)a.getX();
  float y1 = (float)a.getY();
  float x2 = (float)b.getX();
  float y2 = (float)b.getY();
  float y = y2 - y1;
  float x = x2 - x1;
  float rad = atan2(y,x);// + HALF_PI;
  return rad;
}

Point2D_F64 triangulator(Point2D_F64 a, float angle, float distance_one, float distance_two) {
  float x = (float)a.getX();
  float y = (float)a.getY();
  float newX = x + distance_one * sin(angle);
  newX = (float)checkEdge(newX, 640);
  float newY = y + distance_one * cos(angle);
  newY = (float)checkEdge(newY, 480);
  float newAngle = checkPi(angle - HALF_PI);
  double actualX = newX + distance_two + sin(newAngle);
  actualX = checkEdge(actualX, 640);
  double actualY = newY + distance_two + cos(newAngle);
  actualY = checkEdge(actualY, 480);
  Point2D_F64 newP = new Point2D_F64(actualX, actualY);
  return newP;
}

Point2D_F64[] createSquare(Point2D_F64[] points, int qrWidth, int expandX, int expandY) {
  float distance_one = (expandX - qrWidth)/2;
  float distance_two = (expandY - qrWidth)/2;
  Point2D_F64 a = points[0];
  Point2D_F64 b = points[1];
  Point2D_F64 c = points[2];
  Point2D_F64 d = points[3];
  double x = a.getX();
  double y = a.getY();
  // create a new a point
  double newAx = checkEdge(x - distance_two, 640);
  double newAy = checkEdge(y - distance_one, 480);
  Point2D_F64 newA = new Point2D_F64(newAx, newAy);
  // new b point
  x = b.getX();
  y = b.getY();
  double newBx = checkEdge(x - distance_one, 640);
  double newBy = checkEdge(y - distance_two, 480);
  Point2D_F64 newB = new Point2D_F64(newBx, newBy);
  // new c point
  x = c.getX();
  y = c.getY();
  double newCx = checkEdge(x + distance_two, 640);
  double newCy = checkEdge(y + distance_one, 480);
  Point2D_F64 newC = new Point2D_F64(newCx, newCy);
  // new d point
  x = d.getX();
  y = d.getY();
  double newDx = checkEdge(x + distance_one, 640);
  double newDy = checkEdge(y + distance_two, 480);
  Point2D_F64 newD = new Point2D_F64(newDx, newDy);
  Point2D_F64[] newPoints = {newA, newB, newC, newD};
  return newPoints;
}

Point2D_F64 centerPoint(Point2D_F64[] points) {
  // Because it's a square, you can find the center by taking the average of the x coordinates
  // of the corners, and then take the average of the y coordinates of the corners.
  // This will give you the x and y coordinates of the center of the square.
  // I believe this also works for rectangles.
  float sumX = 0.0;
  float sumY = 0.0;
  for (int i = 0; i < points.length; i++) {
    sumX = sumX + (float)points[i].x;
    sumY = sumY + (float)points[i].y;
  };
  sumX = sumX / 4;
  sumY = sumY / 4;
  Point2D_F64 center = new Point2D_F64(sumX, sumY);
  return center;
}

double checkEdge(double p, double edge) {
  if (p < 0) {
    p = 0;
  } else if (p > edge) {
    p = edge;
  }
  return p;
}

double[] expander(double p1, double p2, float ratio, int bound) {
  double absDiff = abs((float)p2-(float)p1);
  double ratioDiff = absDiff * ratio;
  double splitDiff = (ratioDiff - absDiff) / 2;
  double bounds = (double)bound;
  double newP1;
  double newP2;
  if (p1 > p2) {

    newP1 = p1 + splitDiff;
    newP2 = p2 - splitDiff;
  } else {

    newP1 = p1 - splitDiff;
    newP2 = p2 + splitDiff;
  }
  if (newP1 < 0) {
    newP1 = 0;
  } else if (newP1 > bounds) {
    newP1 = bounds;
  }
  if (newP2 < 0) {
    newP2 = 0;
  } else if (newP2 > bounds) {
    newP2 = bounds;
  }

  double[] newPs = new double[2];
  newPs[0] = newP1;
  newPs[1] = newP2;
  return newPs;
}

void initializeCamera( int desiredWidth, int desiredHeight ) {
  String[] cameras = Capture.list();
  /* for (int i = 0; i < cameras.length; i++) { */
  /*   println("[" + i + "] " + cameras[i]); */
  /* }; */
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    cam = new Capture(this, desiredWidth, desiredHeight, 30);
    cam.start();
  }
}
