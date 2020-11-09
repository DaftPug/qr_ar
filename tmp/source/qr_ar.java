import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import boofcv.processing.*; 
import java.util.*; 
import georegression.struct.shapes.Polygon2D_F64; 
import georegression.struct.point.Point2D_F64; 
import boofcv.alg.fiducial.qrcode.QrCode; 

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








Capture cam;
SimpleQrCode detector;

public void setup() {
  // Open up the camera so that it has a video feed to process
  initializeCamera(640, 480);
  surface.setSize(cam.width, cam.height);


  detector = Boof.detectQR();
}

public void draw() {
  if (cam.available() == true) {
    cam.read();

    List<QrCode> found = detector.detect(cam);

    image(cam, 0, 0);

    // Configure the line's appearance
    strokeWeight(5);
    stroke(255, 0, 0);

    for ( QrCode qr : found ) {
      println("message             "+qr.message);


      // Draw a line around each detected QR Code
      beginShape();
      for ( int i = 0; i < qr.bounds.size(); i++ ) {
        Point2D_F64 p = qr.bounds.get(i);
        vertex( (int)p.x, (int)p.y );
      }
      // close the loop
      Point2D_F64 p = qr.bounds.get(0);

      fill(255, 0, 0);
      if (qr.message.charAt(3) == '1') {
        text("Warning!", (int)p.x-10, (int)p.y-10);
      }
      fill(255, 0, 0, 50);
      vertex( (int)p.x, (int)p.y );

      endShape();
    }
  }
}

public void initializeCamera( int desiredWidth, int desiredHeight ) {
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    cam = new Capture(this, desiredWidth, desiredHeight);
    cam.start();
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "qr_ar" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
