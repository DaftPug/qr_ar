import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 
import processing.video.*; 
import boofcv.processing.*; 
import boofcv.struct.image.*; 
import boofcv.alg.fiducial.qrcode.QrCode; 
import milchreis.imageprocessing.*; 
import georegression.struct.shapes.Polygon2D_F64; 
import georegression.struct.point.Point2D_F64; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class qr_ar extends PApplet {

// Launches a webcam and searches for QR Codes, prints their message and draws their outline
// Edited by Victor Permild for Situating Interactions 2020, ITU Copenhagen

/* Overordnet TODO
   - gem og load kendte QR-koder, så de ikke skal generes og modificeres på ny hver gang
   - lav QR-kode generator, som kan lave en masse QR-koder med unikke ID'endDraw
   - lav menu, så QR-koders størrelse kan modificeres

 */

// for Capture

// for qrDetection



// for saturation;

//for Polygon2D_F64 points and shapes



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
HashMap<String, QRObject> qrArray;
int layerLimit;
int debug = 0;
String[] debugText = {""};
StringDict debugInventory;

public void setup() {
  /* size(1280, 480); */
  
  debugInventory = new StringDict();
  qrArray = new HashMap<String, QRObject>();
  debug = 0;
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

public void draw() {

  /* pg.beginDraw(); */
  if (cam.available() == true) {
    cam.read();
    graphics.get(0).beginDraw();
    saturated = Saturation.apply(cam, 0.05f);
    graphics.get(0).image(saturated, 0, 0);
    image(graphics.get(0), 0, 0);
    graphics.get(0).endDraw();

    List<QrCode> found = detector.detect(cam);


    Point2D_F64[] bounds = new Point2D_F64[4];

    // The QR codes being tested have a height and width of 42
    for ( QrCode qr : found ) {

      for ( int i = 0; i < qr.bounds.size(); i++ ) {
        /* println("qr.bounds.get(i):      " + qr.bounds.get(i)); */
        bounds[i] = qr.bounds.get(i);

      }

      if (qrArray.containsKey(qr.message)) {
        QRObject temp = qrArray.get(qr.message);
        /* temp.getGraphics().clear(); */
        temp.updateQRPoints(bounds);
        temp.drawObject();
      } else {
        qrArray.put(qr.message, new QRObject(qr.message, cam));
        qrArray.get(qr.message).updateQRPoints(bounds);
        qrArray.get(qr.message).drawObject();
        println("qrobject [" + qr.message + "] found and created");
      }
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
    if (!qrArray.isEmpty()) {

      image(qrArray.get(qr.message).getGraphics(), 0, 0);
    }
      noStroke();
    }

  }

}

public void saveQRCodes() {
  JSONArray values = new JSONArray();
  if (!qrArray.isEmpty()) {
    int i = 0;
    for (String key : qrArray.keySet()) {
      QRObject tempQR = qrArray.get(key);
      JSONObject qrCode = new JSONObject();
      qrCode.setString("qrID", tempQR.getId());
      qrCode.setFloat("ratioX", tempQR.getRatioX());
      qrCode.setFloat("ratioY", tempQR.getRatioY());
      qrCode.setFloat("offsetX", tempQR.getOffsetX());
      qrCode.setFloat("offsetY", tempQR.getOffsetY());
      values.setJSONObject(i, qrCode);
      i++;
    }
  }
  JSONObject json = new JSONObject();
  json.setJSONArray ("qrCodes", values);
  saveJSONObject(json, "qrcodes.json");
}

public void loadQRCodes() {
  JSONObject json = loadJSONObject("qrcodes.json");
  JSONArray values = json.getJSONArray("qrCodes");

  for (int i = 0; i < values.size(); i++) {
    JSONObject qrCode = values.getJSONObject(i);
    if (!qrArray.containsKey(qrCode.getString("qrID"))) {
      QRObject temp = new QRObject(qrCode.getString("qrID"), cam);
      temp.setRatioX(qrCode.getFloat("ratioX"));
      temp.setRatioY(qrCode.getFloat("ratioY"));
      temp.setOffsetX(qrCode.getFloat("offsetX"));
      temp.setOffsetY(qrCode.getFloat("offsetY"));
      qrArray.put(temp.getId(), temp);
    }

  };
}
public void drawVertices(Point2D_F64[] bounds, Point2D_F64[] newBounds) {
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

public void debugPrint(int textsize) {
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

public void addDebugText(String data) {
  debugText = append(debugText, data);
}

public void colorPoints(Point2D_F64[] points) {
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


}


public float checkPi(float angle) {
  angle = angle + PI;
  if (angle > 2*PI) {
    angle = angle - 2*PI;
  } else if (angle < 0) {
    angle = 2*PI - angle;
  }
  return angle;
}

public double checkEdge(double p, double edge) {
  if (p < 0) {
    p = 0;
  } else if (p > edge) {
    p = edge;
  }
  return p;
}


public void initializeCamera( int desiredWidth, int desiredHeight ) {
  String[] cameras = Capture.list();
  /* for (int i = 0; i < cameras.length; i++) { */
  /*   println("[" + i + "] " + cameras[i]); */
  /* }; */
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    /* cam = new Capture(this, desiredWidth, desiredHeight, 30); */
    cam = new Capture(this, desiredWidth, desiredHeight);
    cam.start();
  }
}

class QRObject {
  // to create unique ID's
  // import java.util.UUID;
  // println(UUID.randomUUID().toString());
  String qrId;
  Point2D_F64[] qrPoints;
  Capture cam;
  float objectWidth;
  float objectHeight;
  PGraphics cammie;
  PGraphics mask;
  float ratioX = 1.0f;
  float ratioY = 1.0f;
  float offsetX = 0.0f;
  float offsetY = 0.0f;


  QRObject(String id, Capture camera) {
    qrId = id;
    cam = camera;
    /* objectWidth = 100.0; */
    /* objectHeight = 100.0; */
    cammie = createGraphics(640, 480);
    mask = createGraphics(640, 480);
  }

  public void drawObject() {
    Point2D_F64 a = qrPoints[0];
    Point2D_F64 b = qrPoints[1];
    Point2D_F64 c = qrPoints[2];
    Point2D_F64 d = qrPoints[3];
    Point2D_F64 center = qrCenter(qrPoints);
    float angle_one = atanifier(a, b);
    float angle_two = atanifier(d, c);
    // they might differ slightly due to viewing angle, so using the average angle to semi-account for this
    float avr_angle = (angle_one + angle_two) / 2;
    /* int token = graphics.size() - 1; */
    cammie.beginDraw();
    cam.read();
    cammie.image(cam, 0, 0);
    mask.beginDraw();
    mask.noStroke();
    /* bg.quad((float)a.x, (float)a.y, (float)b.x, (float)b.y, (float)c.x, (float)c.y, (float)d.x, (float)d.y); */
    mask.rectMode(CENTER);
    mask.pushMatrix();
    mask.translate((float)center.x, (float)center.y);
    mask.rotate(avr_angle);
    float distance = qrDistance(a, b);
    objectWidth = distance * ratioX;
    objectHeight = distance * ratioY;
    mask.rect(0, 0, objectWidth, objectHeight);
    mask.popMatrix();
    mask.endDraw();
    cammie.endDraw();
    cammie.mask(mask);
    mask.clear();
  }

  public void updateQRPoints(Point2D_F64[] newPoints) {
    qrPoints = newPoints;
  }

  public float atanifier(Point2D_F64 a, Point2D_F64 b) {
    float x1 = (float)a.getX();
    float y1 = (float)a.getY();
    float x2 = (float)b.getX();
    float y2 = (float)b.getY();
    float y = y2 - y1;
    float x = x2 - x1;
    float rad = atan2(y,x);// + HALF_PI;
    return rad;
  }

  public float qrDistance(Point2D_F64 a, Point2D_F64 b) {
    float x1 = (float)a.getX();
    float y1 = (float)a.getY();
    float x2 = (float)b.getX();
    float y2 = (float)b.getY();
    float distance = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
    return distance;
  }

  public Point2D_F64 qrCenter(Point2D_F64[] points) {
    // Because it's a square, you can find the center by taking the average of the x coordinates
    // of the corners, and then take the average of the y coordinates of the corners.
    // This will give you the x and y coordinates of the center of the square.
    // I believe this also works for rectangles.
    float sumX = 0.0f;
    float sumY = 0.0f;
    for (int i = 0; i < points.length; i++) {
      sumX = sumX + (float)points[i].x;
      sumY = sumY + (float)points[i].y;
    };
    sumX = sumX / 4;
    sumY = sumY / 4;
    Point2D_F64 center = new Point2D_F64(sumX, sumY);
    return center;
  }
  public void increaseWidth() {
    ratioX += 0.05f;
  }
  public void increaseWidth(float increment) {
    ratioX += increment;
  }

  public void increaseHeight() {
    ratioY += 0.05f;
  }

  public void increaseHeight(float increment) {
    ratioY += increment;
  }

  public void setWidth(float increment) {
    ratioX = increment;
  }

  public void setHeight(float increment) {
    ratioY = increment;
  }

  public float getWidth() {
    return objectWidth;
  }

  public float getHeight() {
    return objectHeight;
  }

  public PGraphics getGraphics() {
    return cammie;
  }

  public String getId() {
    return qrId;
  }

  public float getRatioX() {
    return ratioX;
  }

  public float getRatioY() {
    return ratioY;
  }

  public void setRatioX(float ratio) {
    ratioX = ratio;
  }

  public void setRatioY(float ratio) {
    ratioY = ratio;
  }

  public float getOffsetX() {
    return offsetX;
  }

  public float getOffsetY() {
    return offsetY;
  }

  public void setOffsetX(float offset) {
    offsetX = offset;
  }

  public void setOffsetY(float offset) {
    offsetY = offset;
  }
}
  public void settings() {  size(640, 480); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "qr_ar" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
