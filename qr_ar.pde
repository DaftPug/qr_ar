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
boolean initiated = false;
String[] cameras;
String camChoice = "";
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
HashMap<String, Point2D_F64[]> qrsDetected;
QRRenderer render;
QRMenu options;

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
  /* frameRate(60); */
  frameRate(120);

  size(1280, 720);
  /* size(640, 480); */
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

  initializeGraphics(width, height);



  detector = Boof.detectQR();
  loadQRCodes();
}

void initializeGraphics(int x, int y) {

  bg = createGraphics(x, y);
  menu = createGraphics(x, y);
  cammie = createGraphics(x, y);
  mask = createGraphics(x, y);
  initializeCamera(width, height);
}

void draw() {

  if (initiated) {
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
      if (!showMenu) {
        render.standard();
      } else {
        if (!tutorial) {
          render.menu(keepStill);

        } else {
          render.demo();
        }
      }
      if (!keepStill) {
        if (!tutorial) {
          cam.read();
        }
        stillQRs.clear();
        stillArray.clear();
        List<QrCode> found = detector.detect(cam);
        foundQrs.clear();

        if (found.size() > 0 || tutorial) {

          // Run all the particle systems
          for (ParticleSystem system: systems) {
            system.run();
          }
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
        /* Point2D_F64[] bounds = new Point2D_F64[4]; */

        qrsDetected = new HashMap<String, Point2D_F64[]>();
        // The QR codes being tested have a height and width of 42
        for ( QrCode qr : found ) {

          Point2D_F64[] bounds = new Point2D_F64[4];
          for ( int i = 0; i < qr.bounds.size(); i++ ) {
            bounds[i] = qr.bounds.get(i);

          }
          qrsDetected.put(qr.message, bounds);
        }

        String[] qrMessages = qrsDetected.keySet().toArray(new String[qrsDetected.size()]);
        if (!qrsDetected.isEmpty()) {
          for (int i = 0; i < qrsDetected.size(); i++) {
            /* println("------------------- " + qrMessages[i] + " qrsDetected --------------------"); */
            /* println(qrsDetected.get(qrMessages[i])); */
          };
        }


        for (int i = 0; i < qrMessages.length; i++) {
          QRObject temp;
          QRObject tempStill;
          Point2D_F64[] tempPoints = qrsDetected.get(qrMessages[i]);
          /* println("tempPoints:"); */
          /* println(tempPoints); */
          if (qrArray.containsKey(qrMessages[i])) {
              temp = qrArray.get(qrMessages[i]);
              temp.updateQRPoints(tempPoints);
              foundQrs.put(qrMessages[i], temp);
              tempStill = qrArray.get(qrMessages[i]);
              tempStill.updateQRPoints(tempPoints);
              stillArray.put(qrMessages[i], tempStill);
          } else {
              temp = new QRObject(qrMessages[i], cam);
              tempStill = new QRObject(qrMessages[i], cam);
              qrArray.put(qrMessages[i], temp);
              temp.updateQRPoints(tempPoints);
              foundQrs.put(qrMessages[i], temp);
              tempStill.updateQRPoints(tempPoints);
              stillArray.put(qrMessages[i], tempStill);
              /* qrArray.get(qrMessages[i]).drawObject(); */
              println("new qrobject [" + qrMessages[i] + "] found and created");
          }

        }
      }

      if (showMenu) {
        if (!keepStill && !tutorial) {
          options.update(stillArray, qrArray);
          keepStill = true;
        }
        if (keepStill) {

          render.standardTail(stillArray);
          options.config();
        }
        if (tutorial) {
          if (!stillArray.isEmpty()) {
            render.standardTail(stillArray);
            String[] choices = stillArray.keySet().toArray(new String[stillArray.size()]);
            for (int i = 0; i < stillArray.size(); i++) {
              QRObject temp = stillArray.get(choices[i]);
              temp.updateWidthAndHeight();
              temp.qrParticles(boundaries, systems);

            };
          }
        }
      } else {
        render.standardTail(foundQrs);
        /* println("[!] rendering: " + foundQrs.size() + " QR codes"); */
      }

    // end of if (cam.available) {}
    mask.clear();
    cammie.clear();
    }
  // end of draw()
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
    /* stillArray = new HashMap<String, QRObject>(); */
    /* stillQRs = new ArrayList<PImage>(); */
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
    /* stillArray = new HashMap<String, QRObject>(); */
    /* stillQRs = new ArrayList<PImage>(); */
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


void initializeCamera( int desiredWidth, int desiredHeight ) {
  cameras = Capture.list();
  for (int i = 0; i < cameras.length; i++) {
    println("[" + i + "] " + cameras[i]);
  };
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  }
}

void chooseCam(String _camChoice) {

    cam = new Capture(this, width, height, _camChoice);
    cam.start();
    surface.setSize(cam.width, cam.height);
    render = new QRRenderer(bg, menu, mask, cammie, cam);
    options = new QRMenu(render, stillArray, qrArray);
    initiated = true;
}

void keyPressed() {
  if (!initiated) {
   if (key == '0') {
      chooseCam(cameras[0]);
    }

   if (key == '1') {

      chooseCam(cameras[1]);
    }

   if (key == '2') {
      chooseCam(cameras[2]);

    }

   if (key == '3') {
      chooseCam(cameras[3]);
    }

   if (key == '4') {
      chooseCam(cameras[4]);
    }

   if (key == '5') {
      chooseCam(cameras[5]);
    }

   if (key == '6') {
      chooseCam(cameras[6]);
    }

   if (key == '7') {
      chooseCam(cameras[7]);
    }

   if (key == '8') {
      chooseCam(cameras[8]);
    }

   if (key == '9') {
      chooseCam(cameras[9]);
    }


  }
}
