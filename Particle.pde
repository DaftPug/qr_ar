// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2012
// Box2DProcessing example

// A Particle

class Particle {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float lifespan;

  /* Body body; */

  Particle(PVector l) {
    acceleration = new PVector(0,0.8);
    velocity = new PVector(random(-10,10),random(-10,10));
    location = l.get();
    lifespan = 255.0;

    /* makeBody(new Vec2(l.x,l.y),0.2f); */
  }

  void run() {
    update();
    display();
  }

  // Method to update location
  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    lifespan -= 2.0;
  }

  // Method to display
  void display() {
    stroke(0,lifespan);
    strokeWeight(0);
    int r = (int)random(200, 250);
    int g = (int)random(50, 100);
    int b = (int)random(10, 125);
    fill(r, g, b, lifespan);
    ellipse(location.x,location.y,12,12);
  }

  // Is the particle still useful?
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }

  // This function removes the particle from the box2d world
  /* void killBody() { */
  /*   box2d.destroyBody(body); */
  /* } */

 // This function adds the rectangle to the box2d world
  /* void makeBody(Vec2 center, float r) { */
  /*   // Define and create the body */
  /*   BodyDef bd = new BodyDef(); */
  /*       bd.type = BodyType.DYNAMIC; */

  /*   bd.position.set(box2d.coordPixelsToWorld(center)); */
  /*   body = box2d.createBody(bd); */

  /*   // Give it some initial random velocity */
  /*   body.setLinearVelocity(new Vec2(random(-1,1),random(-1,1))); */

  /*   // Make the body's shape a circle */
  /*   CircleShape cs = new CircleShape(); */
  /*   cs.m_radius = box2d.scalarPixelsToWorld(r); */

  /*   FixtureDef fd = new FixtureDef(); */
  /*   fd.shape = cs; */

  /*   fd.density = 1; */
  /*   fd.friction = 0;  // Slippery when wet! */
  /*   fd.restitution = 0.5; */

  /*   // We could use this if we want to turn collisions off */
  /*   //cd.filter.groupIndex = -10; */

  /*   // Attach fixture to body */
  /*   body.createFixture(fd); */

  /* } */

}
