// Launches a webcam and searches for QR Codes, prints their message and draws their outline
// Edited by Victor Permild for Situating Interactions 2020, ITU Copenhagen

import processing.video.*;
import boofcv.processing.*;
import boofcv.struct.image.*;
import java.util.*;
import georegression.struct.shapes.Polygon2D_F64;
import georegression.struct.point.Point2D_F64;
import boofcv.alg.fiducial.qrcode.QrCode;

Capture cam;
SimpleQrCode detector;
// variable used to find contours
SimpleGray gray;
PImage imgContour;
PImage imgBlobs;
PImage input;

void setup() {

  /* size(1280, 480); */
  // Open up the camera so that it has a video feed to process
  initializeCamera(640, 480);
  surface.setSize(cam.width*2, cam.height);

  detector = Boof.detectQR();
}

void draw() {
  if (cam.available() == true) {
    cam.read();

    List<QrCode> found = detector.detect(cam);

    image(cam, 0, 0);
    image(cam, cam.width, 0);
    // Configure the line's appearance
    strokeWeight(5);
    stroke(255, 0, 0);

    Point2D_F64[] bounds = new Point2D_F64[4];

    // The QR codes being tested have a height and width of 42
    for ( QrCode qr : found ) {
      /* println("message             "+qr.message); */
      /* println("qr.bounds.size():    " +  qr.bounds.size()); */

      // Draw a line around each detected QR Code
      beginShape();
      for ( int i = 0; i < qr.bounds.size(); i++ ) {
        /* println("qr.bounds.get(i):      " + qr.bounds.get(i)); */
        bounds[i] = qr.bounds.get(i);
      }

      Point2D_F64[] newBounds = expandifier(42, 82, 230, bounds);
      for ( int i = 0; i < qr.bounds.size(); i++ ) {
        /* Point2D_F64 p = qr.bounds.get(i); */
        Point2D_F64 p = newBounds[i];
        vertex( (int)p.x, (int)p.y );
      }

      // close the loop
      Point2D_F64 p = newBounds[0];

      /* fill(255, 0, 0); */
      /* if (qr.message.charAt(3) == '1') { */
      /*   text("Warning!", (int)p.x-10, (int)p.y-10); */
      /* } */
      fill(255, 0, 0, 50);
      vertex( (int)p.x, (int)p.y );

      endShape();
    }

  }
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
  bounds[0] = a;
  bounds[1] = b;
  bounds[2] = c;
  bounds[3] = d;
  return bounds;
}

Point2D_F64[] expandifier(int qrWidth, int expandX, int expandY, Point2D_F64[] points) {
  float ratioX = (float)expandX / (float)qrWidth;
  float ratioY = (float)expandY / (float)qrWidth;
  Point2D_F64 a = points[0];
  Point2D_F64 b = points[1];
  Point2D_F64 c = points[2];
  Point2D_F64 d = points[3];
  // extend a -> b & c -> d
  Point2D_F64[] ab = extender(a, b, ratioX);
  Point2D_F64[] cd = extender(c, d, ratioX);
  a = ab[0];
  b = ab[1];
  c = cd[0];
  d = cd[1];
  // extend a -> d & b -> c
  Point2D_F64[] ad = extender(a, d, ratioY);
  Point2D_F64[] bc = extender(b, c, ratioY);
  a = ad[0];
  d = ad[1];
  b = bc[0];
  c = bc[1];
  // gather extended points and return them
  points[0] = a;
  points[1] = b;
  points[2] = c;
  points[3] = d;
  return points;
}


Point2D_F64[] extender(Point2D_F64 a, Point2D_F64 b, float ratio) {
  float x1 = (float)a.getX();
  float y1 = (float)a.getY();
  float x2 = (float)b.getX();
  float y2 = (float)b.getY();
  float distance = getDistance(x1, y1, x2, y2, ratio);
  float angle = atanifier(x1, y1, x2, y2);
  float reverseAngle = checkPi(angle);
  /* println("angle: " + degrees(angle)); */
  /* println("reverseAngle: " + degrees(reverseAngle)); */
  Point2D_F64 newB = extendedPoint(x2, y2, angle, distance);
  Point2D_F64 newA = extendedPoint(x1, y1, reverseAngle, distance);
  Point2D_F64[] extensions = new Point2D_F64[2];
  extensions[0] = newA;
  extensions[1] = newB;

  return extensions;

}

float checkPi(float angle) {
  angle = angle + PI;
  if (angle > 2*PI) {
    angle = angle - 2*PI;
  } else if (angle < 0) {
    angle = 2*PI - angle;
  }
  return angle;
}
float getDistance(float x1, float y1, float x2, float y2, float ratio) {
  float distance = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
  println("distance: " + distance);
  float newDistance = (distance * ratio - distance)/2;
  println("newDistance: "+ newDistance);
  return newDistance;
}

float atanifier(float x1, float y1, float x2, float y2) {
  float y = y2 - y1;
  float x = x2 - x1;
  float rad = atan2(y,x);
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

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    cam = new Capture(this, desiredWidth, desiredHeight);
    cam.start();
  }
}
