
class QRMenu {

  boolean showMenu = false;
  boolean keepStill = false;
  boolean tutorial = false;
  int menuChoice = 0;

  HashMap<String, QRObject> qrArray;
  HashMap<String, QRObject> stillArray;


  QRRenderer render;

  QRMenu(QRRenderer _render, HashMap<String, QRObject> _stillArray, HashMap<String, QRObject> _qrArray) {
    render = _render;
    qrArray = _qrArray;
    stillArray = _stillArray;
  }

  void update(HashMap<String, QRObject> _stillArray, HashMap<String, QRObject> _qrArray) {
    qrArray = _qrArray;
    stillArray = _stillArray;
  }

  void config() {
    int count = 0;
    if (!stillArray.isEmpty()) {
      count = stillArray.size();
    }

    if (count > 0) {
      String[] choices = stillArray.keySet().toArray(new String[stillArray.size()]);

      QRObject temp = stillArray.get(choices[menuChoice]);
      chooser(temp, count);

      render.qrBox(temp);
    }

  }

  void chooser(QRObject qrCode, int qrCount) {

    if (qrCount > 1) {
      if ((keyPressed == true) && (key == 'p')) {
        menuChoice++;
        if (menuChoice == qrCount) {
          menuChoice = 0;
        }
        /* println("Choice: " + menuChoice + " ID: " + qrCode.getId()); */
      }

      if ((keyPressed == true) && (key == 'o')) {
        menuChoice = menuChoice - 1;
        if (menuChoice < 0) {
          menuChoice = qrCount - 1;
        }
        /* println("Choice: " + menuChoice + " ID: " + qrCode.getId()); */
      }
    }
    // Change the size of the rectangle
    if ((keyPressed == true) && (key == CODED)) {
      if (keyCode == UP) {
        qrCode.decreaseRatioY();
      }
      if (keyCode == DOWN) {
        qrCode.increaseRatioY();
      }
      if (keyCode == LEFT) {
        qrCode.decreaseRatioX();
      }
      if (keyCode == RIGHT) {
        qrCode.increaseRatioX();
      }
    }

    // move the rectangle
    if ((keyPressed == true) && (key == 'w')) {
      qrCode.decreaseOffsetY();
    }
    if ((keyPressed == true) && (key == 's')) {
      qrCode.increaseOffsetY();
    }
    if ((keyPressed == true) && (key == 'a')) {
      qrCode.decreaseOffsetX();
    }
    if ((keyPressed == true) && (key == 'd')) {
      qrCode.increaseOffsetX();
    }

    if ((keyPressed == true) && (key == 'x')) {
      String id = qrCode.getId();
      qrArray.put(id, qrCode);
    }
  }

  void demo() {

  }
  void hide() {

  }
}
