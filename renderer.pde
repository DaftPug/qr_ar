
class QRRenderer {
  PGraphics bg;
  PGraphics menu;
  PGraphics mask;
  PGraphics cammie;
  PImage saturated;
  PImage still;
  Capture cam;

  QRRenderer(PGraphics _bg, PGraphics _menu, PGraphics _mask, PGraphics _cammie, Capture _cam) {
    bg = _bg;
    menu = _menu;
    mask = _mask;
    cammie = _cammie;
    cam = _cam;

  }

  void capture() {

  }

  void menu(boolean keepStill) {
    menu.beginDraw();
    if (!keepStill) { // @TODO implement boolean that reacts if a qr is detected
      still = Pixelation.apply(saturated, 10);
    }
    menu.image(still, 0, 0);
    image(menu, 0, 0);
    menu.endDraw();
  }

  void demo() {
    menu.beginDraw();
    menu.image(still, 0, 0);
    image(menu, 0, 0);
    menu.endDraw();

  }

  void standard() {
    bg.beginDraw();
    saturated = Grayscale.apply(cam);
    still = saturated;
    bg.image(saturated, 0, 0);
    image(bg, 0, 0);
    bg.endDraw();
  }

  void standardTail(HashMap<String, QRObject> foundQrs) {
    /* cam.read(); */
    cammie.beginDraw();
    cammie.image(cam, 0, 0);
    mask.beginDraw();
    mask.noStroke();
    mask.rectMode(CENTER);
    drawQRs(foundQrs, mask);
    mask.endDraw();
    cammie.mask(mask);
    image(cammie, 0, 0);
    /* mask.clear(); */
    /* cammie.clear(); */

  }

  void drawQRs(HashMap<String, QRObject> QRs, PGraphics mask) {
    if (!QRs.isEmpty()) {

      String[] qrKeys = QRs.keySet().toArray(new String[QRs.size()]);
      for (int i = 0; i < QRs.size(); i++) {
        QRObject temp = QRs.get(qrKeys[i]);
        /* println("[!] drawn QR x: " + temp.getX() + " y: " + temp.getY()); */
        /* temp.updateWidthAndHeight(); */
        temp.qrMask(mask);
        temp.qrParticles(boundaries, systems);
      };
    }
  }

  PGraphics getStill(QRObject qr) {
    /* PGraphics temp = createGraphics(width, height); */
    PGraphics tempCam = qr.getCam();
    PGraphics tempMask = qr.getMask();
    /* tempCam.clear(); */
    tempCam.beginDraw();
    tempCam.image(cam, 0, 0);
    tempMask.beginDraw();
    tempMask.noStroke();
    tempMask.rectMode(CENTER);
    qr.updateWidthAndHeight();
    qr.qrMask(tempMask);
    tempMask.endDraw();
    tempMask.mask(tempMask);
    tempMask.clear();
    return tempCam;
  }

  void qrBox(QRObject qr) {
    qr.updateWidthAndHeight();
    strokeWeight(5);
    stroke(255, 233, 0);
    pushMatrix();
    translate(qr.getX(), qr.getY());
    rotate(qr.getAngle());
    rectMode(CENTER);
    fill(255, 0);
    rect(0 + qr.getOffsetX(), 0 + qr.getOffsetY(), qr.getWidth(), qr.getHeight());
    noFill();
    popMatrix();
    /* println("qr: " + qr.getId()); */
  }
}
