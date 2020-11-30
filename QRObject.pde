
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
  float increaser = 0.05;
  float ratioX = 1.0;
  float ratioY = 1.0;
  float offsetX = 0.0;
  float offsetY = 0.0;
  tree myTree;
  PVector startPoint;
  PVector drection;
  int count;


  QRObject(String id, Capture camera) {
    qrId = id;
    cam = camera;
    cammie = createGraphics(width, height);
    mask = createGraphics(width, height);

  }

  void qrParticles(ArrayList<ParticleSystem> systems) {
    float cX = (float)center.x;
    float cY = (float)center.y;

    float diffX = cX/25 + objectWidth/2;
    float diffY = cY/25 + objectHeight/2;
    /* float diffX = cX/10 + objectWidth/2; */
    /* float diffY = cY/10 + objectHeight/2; */

    systems.add(new ParticleSystem(2, new PVector(cX - diffX, cY - diffY)));
    systems.add(new ParticleSystem(2, new PVector(cX + diffX, cY - diffY)));
    /* systems.add(new ParticleSystem(2, new PVector(cX + diffX, cY - diffY))); */
    /* systems.add(new ParticleSystem(2, new PVector(cX + diffX, cY - diffY))); */
  }

  float[] transCalc() {
    float x = (float)center.x;
    float y = (float)center.y;
    float transx = width/2;
    float transy = height/2;
    if (x != transx) {
      transx = x - transx;
    }
    if (y != transy) {
      transy = y - transy;
    }
    float transxy[] = {transx, transy};
    return transxy;
  }

  void qrDrawTree() {
    float[] transXY = transCalc();
    float _x = transXY[0];
    float _y = transXY[1];
    pushMatrix();
    translate(_x, _y);
    rotate(avr_angle);
    myTree.swing();
    stroke(80, 0, 50, 200);
    for(int i = 1; i < count; i ++) {
      strokeWeight(myTree.twig[(int)myTree.map[i].x].thickness[(int)myTree.map[i].y]);
      line(myTree.twig[(int)myTree.map[i].x].location[(int)myTree.map[i].y - 1].x, myTree.twig[(int)myTree.map[i].x].location[(int)myTree.map[i].y - 1].y,
           myTree.twig[(int)myTree.map[i].x].location[(int)myTree.map[i].y].x, myTree.twig[(int)myTree.map[i].x].location[(int)myTree.map[i].y].y);
    }

    noStroke();
    for(int i = 0; i < myTree.twig.length; i++) {
      int num = myTree.twig[i].location.length - 1;
      int r = (int)random(50, 250);
      int g = (int)random(50, 250);
      int b = (int)random(50, 250);
      fill(r, g, b);
      ellipse(myTree.twig[i].location[num].x, myTree.twig[i].location[num].y, 12, 12);
    }
    popMatrix();



  }


  PGraphics getCam() {
    return cammie;
  }

  PGraphics getMask() {
    return mask;
  }

  void qrMask(PGraphics _mask) {
    float cX = (float)center.x;
    float cY = (float)center.y;
    _mask.pushMatrix();
    _mask.translate(cX, cY);
    _mask.rotate(getAngle());
    _mask.rect(0 + offsetX, 0 + offsetY, objectWidth, objectHeight);
    _mask.popMatrix();
  }

  void updateQRPoints(Point2D_F64[] newPoints) {
    qrPoints = newPoints;
    center = qrCenter(qrPoints);
    updateWidthAndHeight();
    float bot = (float)center.y + objectHeight/2;
    if (myTree == null) {
      /* startPoint = new PVector(0.0, 0.0); */
      /* startPoint = new PVector((float)center.x, bot); */
      startPoint = new PVector(width/2, height/2);
      drection = new PVector(0, -height);
      myTree = new tree(startPoint, drection);
      count = myTree.treeSize;
    }
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

  void increaseRatioX() {
    ratioX += increaser;
  }

  void decreaseRatioX() {
    ratioX -= increaser;
  }

  void increaseWidth(float increment) {
    ratioX += increment;
  }

  void increaseRatioY() {
    ratioY += increaser;
  }

  void decreaseRatioY() {
    ratioY -= increaser;
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
    /* println("x:" + x); */
    /* println("y:" + y); */
    float[] xy = {x, y};

    /* println("xy:" + xy); */
    return xy;
  }

  float getX() {
    float x = (float)center.x;
    return x;
  }

  float getY() {
    float y = (float)center.y;
    return y;
  }

  float getAngle() {
    Point2D_F64 a = qrPoints[0];
    Point2D_F64 b = qrPoints[1];
    Point2D_F64 c = qrPoints[2];
    Point2D_F64 d = qrPoints[3];
    center = qrCenter(qrPoints);
    float angle_one = atanifier(a, b);
    float angle_two = atanifier(d, c);
    // they might differ slightly due to viewing angle, so using the average angle to semi-account for this
    float new_angle = (angle_one + angle_two) / 2;
    return new_angle;
  }

  void increaseOffsetX() {
    offsetX += (increaser * 10);
  }

  void increaseOffsetY() {
    offsetY += (increaser * 10);
  }

  void decreaseOffsetX() {
    offsetX -= (increaser * 10);
  }

  void decreaseOffsetY() {
    offsetY -= (increaser * 10);
  }
}
