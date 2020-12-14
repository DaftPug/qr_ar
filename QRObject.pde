
class QRObject {
  // to create unique ID's
  // import java.util.UUID;
  // println(UUID.randomUUID().toString());
  String qrId;
  Point2D_F64[] qrPoints;
  Point2D_F64 center;
  Capture cam;
  float objectWidth;
  float objectHeight;
  float avr_angle;
  PGraphics cammie;
  PGraphics mask;
  float ratioX = 1.0;
  float ratioY = 1.0;
  float offsetX = 0.0;
  float offsetY = 0.0;


  QRObject(String id, Capture camera) {
    qrId = id;
    cam = camera;
    /* objectWidth = 100.0; */
    /* objectHeight = 100.0; */
    cammie = createGraphics(640, 480);
    mask = createGraphics(640, 480);
  }

  void drawObject() {
    Point2D_F64 a = qrPoints[0];
    Point2D_F64 b = qrPoints[1];
    Point2D_F64 c = qrPoints[2];
    Point2D_F64 d = qrPoints[3];
    center = qrCenter(qrPoints);
    float angle_one = atanifier(a, b);
    float angle_two = atanifier(d, c);
    // they might differ slightly due to viewing angle, so using the average angle to semi-account for this
    avr_angle = (angle_one + angle_two) / 2;
    /* int token = graphics.size() - 1; */
    cammie.beginDraw();
    cam.read();
    cammie.image(cam, 0, 0);
    mask.beginDraw();
    mask.noStroke();
    mask.rectMode(CENTER);
    mask.pushMatrix();
    mask.translate((float)center.x, (float)center.y);
    mask.rotate(avr_angle);
    float distance = qrDistance(a, b);
    objectWidth = distance * ratioX;
    objectHeight = distance * ratioY;
    mask.rect(0, 0, objectWidth, objectHeight);
    /* mask.rect(200, 0, objectWidth, objectHeight); */
    mask.popMatrix();
    mask.endDraw();
    cammie.endDraw();
    cammie.mask(mask);
    mask.clear();
  }

  void updateQRPoints(Point2D_F64[] newPoints) {
    qrPoints = newPoints;
    center = qrCenter(qrPoints);
  }

  void updateWidthAndHeight() {
    Point2D_F64 a = qrPoints[0];
    Point2D_F64 b = qrPoints[1];
    float distance = qrDistance(a, b);
    objectWidth = distance * ratioX;
    objectHeight = distance * ratioY;
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

  float qrDistance(Point2D_F64 a, Point2D_F64 b) {
    float x1 = (float)a.getX();
    float y1 = (float)a.getY();
    float x2 = (float)b.getX();
    float y2 = (float)b.getY();
    float distance = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
    return distance;
  }

  Point2D_F64 qrCenter(Point2D_F64[] points) {
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

  void increaseWidth() {
    ratioX += 0.05;
  }

  void increaseWidth(float increment) {
    ratioX += increment;
  }

  void increaseHeight() {
    ratioY += 0.05;
  }

  void increaseHeight(float increment) {
    ratioY += increment;
  }

  void setWidth(float increment) {
    ratioX = increment;
  }

  void setHeight(float increment) {
    ratioY = increment;
  }

  float getWidth() {
    return objectWidth;
  }

  float getHeight() {
    return objectHeight;
  }

  PGraphics getGraphics() {
    return cammie;
  }

  String getId() {
    return qrId;
  }

  float getRatioX() {
    return ratioX;
  }

  float getRatioY() {
    return ratioY;
  }

  void setRatioX(float ratio) {
    ratioX = ratio;
  }

  void setRatioY(float ratio) {
    ratioY = ratio;
  }

  float getOffsetX() {
    return offsetX;
  }

  float getOffsetY() {
    return offsetY;
  }

  void setOffsetX(float offset) {
    offsetX = offset;
  }

  void setOffsetY(float offset) {
    offsetY = offset;
  }

  float[] getCenter() {
    float x = (float)center.x;
    float y = (float)center.y;
    println("x:" + x);
    println("y:" + y);
    float[] xy = {x, y};

    println("xy:" + xy);
    return xy;
  }

  float getAngle() {
    return avr_angle;
  }

}
