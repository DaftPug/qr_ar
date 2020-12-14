// Launches a webcam and searches for QR Codes, prints their message and draws their outline
// Edited by Victor Permild for Situating Interactions 2020, ITU Copenhagen

/* Overordnet TODO
   - gem og load kendte QR-koder, så de ikke skal generes og modificeres på ny hver gang
   - lav QR-kode generator, som kan lave en masse QR-koder med unikke ID'endDraw
   - lav menu, så QR-koders størrelse kan modificeres

 */
import java.util.*;
/* import java.awt.event.KeyEvent; */
import processing.event.*;
// for Capture
import processing.video.*;
// for qrDetection
import boofcv.processing.*;
import boofcv.struct.image.*;
import boofcv.alg.fiducial.qrcode.QrCode;
// for saturation;
import milchreis.imageprocessing.*;
// for Polygon2D_F64 points and shapes
import georegression.struct.shapes.Polygon2D_F64;
import georegression.struct.point.Point2D_F64;
// for particles
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

Capture cam;
SimpleQrCode detector;
// variable used to find contours
SimpleGray gray;
boolean showMenu = false;
boolean keepStill = false;
boolean tutorial = false;
PImage imgContour;
PImage imgBlobs;
PImage input;
PImage test;
PImage saturated;
PImage still;
PShape ps;
PGraphics pg;
PGraphics bg;
PGraphics menu;
PGraphics mask;
PGraphics cammie;
File tempFile;
ArrayList<PImage> stillQRs = new ArrayList<PImage>();
/* ArrayList<PGraphics> graphics = new ArrayList<PGraphics>(); */
HashMap<String, QRObject> qrArray;
HashMap<String, QRObject> foundQrs;
HashMap<String, QRObject> stillArray;

// Particle variables
// A reference to our box2d world
Box2DProcessing box2d;

// A list we'll use to track fixed objects
ArrayList<Boundary> boundaries;
/* PImage bg; */
// A list for all particle systems
ArrayList<ParticleSystem> systems;

// Particle variables end

int layerLimit;
int debug = 0;
int menuChoice = 0;
String[] debugText = {""};
StringDict debugInventory;

void setup() {
  frameRate(60);

  /* size(1280, 480); */
  /* size(640, 480, P3D); */
  /* size(640,480); */
  size(1280, 720);
  smooth();

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();

  // We are setting a custom gravity
  /* box2d.setGravity(30, -60); */
  box2d.setGravity(0, 0);


  // Create ArrayLists
  systems = new ArrayList<ParticleSystem>();
  boundaries = new ArrayList<Boundary>();

  debugInventory = new StringDict();
  qrArray = new HashMap<String, QRObject>();
  stillArray = new HashMap<String, QRObject>();
  foundQrs = new HashMap<String, QRObject>();
  debug = 0;
  /* size(1280, 480); */
  // Open up the camera so that it has a video feed to process
  /* initializeCamera(640, 480); */
  initializeCamera(1280, 720);
  /* graphics.add(createGraphics(640,480)); */
  /* pg = createGraphics(640, 480); */
  /* bg = createGraphics(640, 480); */
  bg = createGraphics(1280, 720);
  /* menu = createGraphics(640, 480); */
  menu = createGraphics(1280, 720);
  /* cammie = createGraphics(640, 480); */
  cammie = createGraphics(1280, 720);
  /* mask = createGraphics(640, 480); */
  mask = createGraphics(1280, 720);
  /* cammi = createGraphics(640, 480); */

  if (debug > 0) {
    surface.setSize(cam.width*2, cam.height);
  } else {
    surface.setSize(cam.width, cam.height);
  }

  detector = Boof.detectQR();
  loadQRCodes();
}

void draw() {
  if((keyPressed == true) && (key == 'c')) {
    toggleMenu();
  }
  if((keyPressed == true) && (key == 't')) {
    toggleTest();
  }

  box2d.step();
  box2d.step();
  box2d.step();
  if (cam.available() == true) {
    cam.read();
    if (!showMenu) {
      bg.beginDraw();
      /* saturated = Saturation.apply(cam, 0.05); */
      saturated = Grayscale.apply(cam);
      /* if (foundQrs.size() > 0) { */
      /*   saturated = Pixelation.apply(saturated, 15); */
      /* } */
      still = saturated;
      bg.image(saturated, 0, 0);
      image(bg, 0, 0);
      bg.endDraw();
    } else {
      if (!tutorial) {
        menu.beginDraw();
        if (!keepStill) {
          still = Pixelation.apply(saturated, 10);
        }
        menu.image(still, 0, 0);
        image(menu, 0, 0);
        menu.endDraw();
      } else {
        menu.beginDraw();
        menu.image(still, 0, 0);
        image(menu, 0, 0);
        menu.endDraw();
      }
    }
    List<QrCode> found = detector.detect(cam);
    foundQrs.clear();

    if (found.size() > 0 || tutorial) {

      // Run all the particle systems
      for (ParticleSystem system: systems) {
        system.run();

        //int n = (int) random(0,2);
        /* system.addParticles(1); */
      }

      // Display all the boundaries
      /* for (Boundary wall: boundaries) { */
      /*   wall.display(); */
      /* } */
    } else {
      if (!tutorial) {
        while(!boundaries.isEmpty()) {
          boundaries.remove(0);
        }
        /* boundaries.clear(); */
        while(!systems.isEmpty()) {
          systems.remove(0);
        }
      }
      /* systems.clear(); */
    }
    Point2D_F64[] bounds = new Point2D_F64[4];

    // The QR codes being tested have a height and width of 42
    for ( QrCode qr : found ) {

      for ( int i = 0; i < qr.bounds.size(); i++ ) {
        bounds[i] = qr.bounds.get(i);

      }
      if (!showMenu) {
        if (qrArray.containsKey(qr.message)) {
          QRObject temp = qrArray.get(qr.message);
          /* temp.getGraphics().clear(); */
          temp.updateQRPoints(bounds);
          foundQrs.put(qr.message, temp);
          temp.drawObject();
        } else {
          QRObject temp = new QRObject(qr.message, cam);
          qrArray.put(qr.message, temp);
          temp.updateQRPoints(bounds);
          /* qrArray.get(qr.message).updateQRPoints(bounds); */
          foundQrs.put(qr.message, temp);
          qrArray.get(qr.message).drawObject();
          println("qrobject [" + qr.message + "] found and created");
        }
      }
      if (debug > 0) {
        debugPrint(8);
        colorPoints(bounds);
      }
      if (debug > 1) {
        String printpoints = "";
        for (int j = 0; j < bounds.length; j++) {
          printpoints = printpoints + bounds[j].toString();
        };
        debugInventory.set("bounds: ", printpoints);
      }
      if (!qrArray.isEmpty()) {
        if (!showMenu) {
          /* image(qrArray.get(qr.message).getGraphics(), 0, 0); */

        } else {
          if (!keepStill) {
            stillArray.put(qr.message, qrArray.get(qr.message));
            stillQRs.add(qrArray.get(qr.message).getGraphics());
            /* image(qrArray.get(qr.message).getGraphics(), 0, 0); */
          }
        }
      }
      noStroke();
    }
    if (showMenu) {
      if (!keepStill && !tutorial) {
        keepStill = true;
      }
      if (keepStill) {
        if (!stillQRs.isEmpty()) {
          for (int i = 0; i < stillQRs.size(); i++) {
            image(stillQRs.get(i), 0, 0);
          };
        }
        if (!stillArray.isEmpty()) {
          String[] choices = stillArray.keySet().toArray(new String[stillArray.size()]);
          QRObject chosen = stillArray.get(choices[menuChoice]);
          float chosenWidth = chosen.getWidth();
          float chosenHeight = chosen.getHeight();
          float chosenRatioX = chosen.getRatioX();
          float chosenRatioY = chosen.getRatioY();
          float chosenOffsetX = chosen.getOffsetX();
          float chosenOffsetY = chosen.getOffsetY();
          float[] chosenCenter = chosen.getCenter();
          float chosenAngle = chosen.getAngle();

          if (stillArray.size() > 1) {
            if ((keyPressed == true) && (key == 'p')) {
              menuChoice++;
              if (menuChoice == stillArray.size()) {
                menuChoice = 0;
              }
            }

            if ((keyPressed == true) && (key == 'o')) {
              menuChoice = menuChoice - 1;
              if (menuChoice < 0) {
                menuChoice = stillArray.size() - 1;
              }
            }
          }
          // Change the size of the rectangle
          if ((keyPressed == true) && (key == CODED)) {
            if (keyCode == UP) {
              chosenRatioY += 0.05;
              chosen.setRatioY(chosenRatioY);
            }
            if (keyCode == DOWN) {
              chosenRatioY -= 0.05;
              chosen.setRatioY(chosenRatioY);
            }
            if (keyCode == LEFT) {
              chosenRatioX -= 0.05;
              chosen.setRatioX(chosenRatioX);
            }
            if (keyCode == RIGHT) {
              chosenRatioX += 0.05;
              chosen.setRatioX(chosenRatioX);
            }
          }

          // move the rectangle
          if ((keyPressed == true) && (key == 'w')) {
            chosenOffsetY += 0.5;
            chosen.setOffsetY(chosenOffsetY);
          }
          if ((keyPressed == true) && (key == 's')) {
            chosenOffsetY -= 0.5;
            chosen.setOffsetY(chosenOffsetY);
          }
          if ((keyPressed == true) && (key == 'a')) {
            chosenOffsetX -= 0.5;
            chosen.setOffsetX(chosenOffsetX);
          }
          if ((keyPressed == true) && (key == 'd')) {
            chosenOffsetX += 0.5;
            chosen.setOffsetX(chosenOffsetX);
          }

          if ((keyPressed == true) && (key == 'x')) {
            String id = chosen.getId();
            qrArray.get(id).setRatioX(chosenRatioX);
            qrArray.get(id).setRatioY(chosenRatioY);
            qrArray.get(id).setOffsetX(chosenOffsetX);
            qrArray.get(id).setOffsetY(chosenOffsetY);
          }
          chosen.updateWidthAndHeight();
          strokeWeight(5);
          stroke(255, 233, 0);
          pushMatrix();
          translate(chosenCenter[0], chosenCenter[1]);
          rotate(chosenAngle);
          rectMode(CENTER);
          fill(255, 0);
          rect(0 + chosenOffsetX, 0 + chosenOffsetY, chosen.getWidth(), chosen.getHeight());
          noFill();
          popMatrix();
        }

      }
        if (tutorial) {
          if (!stillQRs.isEmpty() && !stillArray.isEmpty()) {

            String[] choices = stillArray.keySet().toArray(new String[stillArray.size()]);
            for (int i = 0; i < stillArray.size(); i++) {

              QRObject temp = stillArray.get(choices[i]);
              image(stillQRs.get(i), 0, 0);
              float offsetX = temp.getOffsetX();
              float offsetY = temp.getOffsetY();
              float[] center = temp.getCenter();
              float angle = temp.getAngle();
              float qrWidth = temp.getWidth();
              float qrHeight = temp.getHeight();
              boundaries.add(new Boundary(center[0] + offsetX, center[1] + offsetY, qrWidth, qrHeight, 0));

              float diffX = center[0]/10 + qrWidth/2;
              float diffY = center[1]/10 + qrHeight/2;
              systems.add(new ParticleSystem(2, new PVector(center[0] - diffX, center[1] - diffY)));
              systems.add(new ParticleSystem(2, new PVector(center[0] + diffX, center[1] - diffY)));
            };
          }
          /* if (!stillArray.isEmpty()) { */
          /*   String[] choices = stillArray.keySet().toArray(new String[stillArray.size()]); */
          /*   QRObject chosen = stillArray.get(choices[menuChoice]); */
          /*   float chosenWidth = chosen.getWidth(); */
          /*   float chosenHeight = chosen.getHeight(); */
          /*   float chosenRatioX = chosen.getRatioX(); */
          /*   float chosenRatioY = chosen.getRatioY(); */
          /*   float chosenOffsetX = chosen.getOffsetX(); */
          /*   float chosenOffsetY = chosen.getOffsetY(); */
          /*   float[] chosenCenter = chosen.getCenter(); */
          /*   float chosenAngle = chosen.getAngle(); */
          /*   chosen.updateWidthAndHeight(); */
          /*   strokeWeight(5); */
          /*   stroke(255, 233, 0); */
          /*   pushMatrix(); */
          /*   translate(chosenCenter[0], chosenCenter[1]); */
          /*   rotate(chosenAngle); */
          /*   rectMode(CENTER); */
          /*   fill(255, 0); */
          /*   rect(0 + chosenOffsetX, 0 + chosenOffsetY, chosen.getWidth(), chosen.getHeight()); */
          /*   noFill(); */
          /*   popMatrix(); */

        /* } */
      }
    } else {
      cam.read();
      cammie.beginDraw();
      cammie.image(cam, 0, 0);
      mask.beginDraw();
      mask.noStroke();
      mask.rectMode(CENTER);
      drawQRs(foundQrs, mask);
      mask.endDraw();
      cammie.mask(mask);
      mask.clear();
      image(cammie, 0, 0);
      cammie.clear();
    }

  // end of if (cam.available) {}
  }
  // end of draw()
}

void drawQRs(HashMap<String, QRObject> QRs, PGraphics mask) {
  if (!QRs.isEmpty()) {

    String[] qrKeys = QRs.keySet().toArray(new String[QRs.size()]);
    for (int i = 0; i < QRs.size(); i++) {
      QRObject temp = QRs.get(qrKeys[i]);
      float offsetX = temp.getOffsetX();
      float offsetY = temp.getOffsetY();
      float[] center = temp.getCenter();
      float angle = temp.getAngle();
      float qrWidth = temp.getWidth();
      float qrHeight = temp.getHeight();
      mask.pushMatrix();
      mask.translate(center[0], center[1]);
      mask.rotate(angle);
      /* float distance = qrDistance(a, b); */
      /* objectWidth = distance * ratioX; */
      /* objectHeight = distance * ratioY; */
      mask.rect(0 + offsetX, 0 + offsetY, qrWidth, qrHeight);
      mask.popMatrix();

      boundaries.add(new Boundary(center[0] + offsetX, center[1] + offsetY, qrWidth, qrHeight, 0));

      /* systems.add(new ParticleSystem(1, new PVector(center[0] - (qrWidth + 5), center[1] - (qrHeight + 5)))); */

      /* box2d.setGravity(30, -30); */
      /* systems.add(new ParticleSystem(1, new PVector(0, 0))); */
      float diffX = center[0]/10 + qrWidth/2;
      float diffY = center[1]/10 + qrHeight/2;
      systems.add(new ParticleSystem(2, new PVector(center[0] - diffX, center[1] - diffY)));
      /* box2d.setGravity(0, -30); */
      systems.add(new ParticleSystem(2, new PVector(center[0] + diffX, center[1] - diffY)));
      /* systems.add(new ParticleSystem(1, new PVector(center[0] + diffX, center[1] - diffY))); */
      /* systems.add(new ParticleSystem(1, new PVector(center[0] + diffX, center[1] + diffX))); */
      /* box2d.setGravity(-30, -30); */
      /* systems.add(new ParticleSystem(1, new PVector(0, width))); */
    };
  }
}

void toggleTest() {
  if (tutorial) {
    saveQRCodes();
    /* toggleStill(); */
    showMenu = false;
    tutorial = false;
  } else {
    menuChoice = 0;
    stillArray = new HashMap<String, QRObject>();
    stillQRs = new ArrayList<PImage>();
    showMenu = true;
    tutorial = true;
  }
}

void toggleStill() {
  if (keepStill) {
    keepStill = false;
  } else {
    keepStill = true;
  }
}

void toggleMenu() {
  if (showMenu) {
    saveQRCodes();
    toggleStill();
    showMenu = false;
  } else {
    menuChoice = 0;
    stillArray = new HashMap<String, QRObject>();
    stillQRs = new ArrayList<PImage>();
    showMenu = true;
  }
}

void saveQRCodes() {
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

void loadQRCodes() {
    try {
      println("[!] Loading QR codes");
      JSONObject json = loadJSONObject("qrcodes.json");
      JSONArray values = json.getJSONArray("qrCodes");
      println("[!] " + values.size() + " QR codes found");
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
    } catch(NullPointerException e) {
      println("No file named qrcodes.json found");
      e.printStackTrace();
    }



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

double checkEdge(double p, double edge) {
  if (p < 0) {
    p = 0;
  } else if (p > edge) {
    p = edge;
  }
  return p;
}

void initializeCamera( int desiredWidth, int desiredHeight ) {
  String[] cameras = Capture.list();
  for (int i = 0; i < cameras.length; i++) {
    println("[" + i + "] " + cameras[i]);
  };
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    /* cam = new Capture(this, desiredWidth, desiredHeight, 30); */
    /* cam = new Capture(this, desiredWidth, desiredHeight, "HP Webcam 1300"); */
    cam = new Capture(this, desiredWidth, desiredHeight, cameras[2]);
    cam.start();
  }
}
