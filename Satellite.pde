class Satellite {
  String name;
  PVector[] path;
  int currentIndex = 0;
  float radius = 1;
  float timeStep = 1;  // Time in seconds to move between positions
  int fps = 60;         // Frames per second
  float progressIncrement;
  float lerpProgress = 0;  // Tracks interpolation progress between points
  PVector currentPos;      // Current position
  PVector nextPos;         // Next position in the path
  PVector interpolatedPos; // Smoothly interpolated position

  Satellite(String name, PVector[] path) {
    this.name = name;
    this.path = path;
    if (path.length > 1) {
      currentPos = path[0];
      nextPos = path[1];
      interpolatedPos = currentPos.copy();
      progressIncrement = 1.0 / (timeStep * fps);
    }
  }

  void drawPath() {
    stroke(255, 0, 0, 25);
    noFill();
    beginShape();
    for (PVector pos : path) {
      vertex(pos.x, pos.y, pos.z);
    }
    endShape();
  }

  void drawSatellite() {
    if (interpolatedPos != null) {
      pushMatrix();
      translate(interpolatedPos.x, interpolatedPos.y, interpolatedPos.z);
      //fill(255);
      stroke(255);
      strokeWeight(2);
      point(0, 0);
      //sphere(radius);
      popMatrix();
      
      stroke(200, 200, 0);
      strokeWeight(0.01);
      line(interpolatedPos.x, interpolatedPos.y, interpolatedPos.z, 0, 0, 0);

      // Display satellite name
      //pushMatrix();
      //translate(interpolatedPos.x + 10, interpolatedPos.y + 10, interpolatedPos.z + 10);
      //fill(255);
      //textSize(12);
      //text(name, 0, 0);
      //popMatrix();
    }
  }

  void moveSatellite() {
    if (path.length > 1) {
      lerpProgress += progressIncrement;  // Increment progress based on time step
      if (lerpProgress >= 1) {
        // Transition to the next segment
        lerpProgress = 0;
        currentIndex = (currentIndex + 1) % path.length;
        currentPos = path[currentIndex];
        nextPos = path[(currentIndex + 1) % path.length];
      }
      // Smoothly interpolate between currentPos and nextPos
      interpolatedPos = PVector.lerp(currentPos, nextPos, lerpProgress);
    }
  }
}
