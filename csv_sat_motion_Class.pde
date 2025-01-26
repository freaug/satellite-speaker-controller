import peasy.*;
import java.io.BufferedReader;

PeasyCam cam;
float rotationSpeed = 0.01;  // Speed of camera rotation
float zoomSpeed = 0.05;  // Speed of zooming out
float time = 0;  // Time variable to control the camera's motion

float earthRadius = 100;  // Radius of the Earth in pixels
ArrayList<Satellite> satellites;  // List to hold satellite objects

boolean animate = false;
float rotateY = 0;
float rotateX = 0;
int pMillis;

void setup() {
  size(800, 800, P3D);
  cam = new PeasyCam(this, 250);  // Initialize PeasyCam
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(1000);

  satellites = new ArrayList<Satellite>();

  // Load satellite data and create satellite objects
  loadSatellites("satellite_positions.csv");
}

void draw() {
  background(25);
  //lights();

  // Draw Earth
  pushMatrix();
  fill(0, 100, 255);  // Blue for Earth
  noStroke();
  sphere(earthRadius);
  popMatrix();

  drawLocation(33.7501, -84.3885, earthRadius);

  // Draw each satellite
  for (Satellite sat : satellites) {
    //sat.drawPath();
    sat.drawSatellite();
    sat.moveSatellite();
  }
  //if (animate) {
  moveCamera();
  //}
}

// Draw a smaller sphere representing a location using lat/lon
void drawLocation(float lat, float lon, float radius) {
  float latRadians = radians(lat);
  float lonRadians = radians(lon);

  // Convert lat/lon to Cartesian coordinates
  float x = radius * cos(latRadians) * cos(lonRadians);
  float y = radius * cos(latRadians) * sin(lonRadians);
  float z = radius * sin(latRadians);

  // Draw the location
  pushMatrix();
  translate(x+3, y+3, z +3);
  fill(100, 255, 50); // Red for the location
  noStroke();
  sphere(1); // Small sphere to mark the location
  popMatrix();
}

void moveCamera() {

  // Zoom out by adjusting the camera's distance


  if (animate) {
    if (rotateY <= 0.02) {
      rotateY += 0.0001;
    }
    if (rotateX <= 0.05) {
      rotateX += 0.0002;
    }
  } else {
    if (rotateY >= 0) {
      rotateY -= 0.0001 ;
    }
    if (rotateX >= 0) {
      rotateX -= 0.0002;
    }
  }

  // Rotate around the Y-axis (horizontal rotation) and X-axis (vertical rotation)
  cam.rotateY(rotationSpeed * rotateY);  // Rotate around the Y-axis (horizontal movement)
  cam.rotateX(rotationSpeed * rotateX);  // Rotate around the X-axis (slower vertical movement)

  cam.lookAt(0, 0, 0);
}

void keyReleased() {
  if (key == 'a') {
    animate = !animate;
  }
  if (key == 'z') {
    cam.setDistance(800, 15000);
  }
}
// Load satellites from the CSV file
void loadSatellites(String filename) {
  try {
    BufferedReader reader = createReader(filename);
    String line = reader.readLine();  // Skip header

    HashMap<String, ArrayList<PVector>> satellitePaths = new HashMap<>();

    while ((line = reader.readLine()) != null) {
      String[] parts = split(line, ",");
      if (parts.length == 5) {
        String name = parts[0];
        float x = float(parts[2]) * (earthRadius / 6371.0);  // Scale to fit Earth radius
        float y = float(parts[3]) * (earthRadius / 6371.0);
        float z = float(parts[4]) * (earthRadius / 6371.0);
        PVector position = new PVector(x, y, z);

        // Group positions by satellite name
        if (!satellitePaths.containsKey(name)) {
          satellitePaths.put(name, new ArrayList<PVector>());
        }
        satellitePaths.get(name).add(position);
      }
    }
    reader.close();

    // Create Satellite objects
    for (String name : satellitePaths.keySet()) {
      ArrayList<PVector> path = satellitePaths.get(name);
      satellites.add(new Satellite(name, path.toArray(new PVector[0])));
    }
  }
  catch (Exception e) {
    println("Error loading satellite positions: " + e.getMessage());
  }
}
