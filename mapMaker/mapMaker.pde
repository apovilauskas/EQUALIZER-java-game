int cols = 40;
int rows = 30;
int cellSize = 20; 
int[][] grid;
int brushType = 2; 
String[] typeNames = {"Player (0)", "Floor (1)", "Wall (2)", "Enemy (3)", "Speed (4)", "Goal (5)"};
color[] colors = {
  color(0, 0, 255),color(255),color(255, 20, 147),color(255, 0, 0),color(0, 150, 255),color(255, 255, 0)
};
boolean newDim = false;
String dimInput = "";

void setup() {
  surface.setResizable(true);
  surface.setTitle("Map editor");
  initMap(40, 30);
}

void draw() {

  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      fill(colors[grid[x][y]]);
      stroke(20);
      rect(x * cellSize, y * cellSize, cellSize, cellSize);
    }
  }
  
  drawUI();
}

void drawUI() {
  fill(60); 
  rect(0, height - 100, width, 100);
  
  fill(255); textSize(14);
  text("BRUSH: " + typeNames[brushType], 20, height - 70);
  fill(colors[brushType]); 
  if (brushType == 2) stroke(0, 255, 255);
  rect(160, height - 85, 20, 20);
  
  fill(255); textSize(12);
  text("KEYS: 0-5: Brush | S: Save | L: Load | N: New map", 20, height - 30);
  
  if (newDim) {
    fill(0, 200, 200);
    rect(width/2 - 150, height/2 - 50, 300, 100);
    
    fill(255); 
    textAlign(CENTER, CENTER);
    text("ENTER DIMENSIONS:", width/2, height/2 - 20);
    textSize(20);
    text(dimInput, width/2, height/2 + 20);
    textAlign(LEFT, BASELINE);
  }
}

void mousePressed() {
  if (newDim) return;
  int x = mouseX / cellSize;
  int y = mouseY / cellSize;
  
  if (x >= 0 && x < cols && y >= 0 && y < rows) {
    // TOGGLE DELETE: If the tile is already the brush type, turn it back to Floor (1)
    if (grid[x][y] == brushType) {
      grid[x][y] = 1; 
    } else {
      paint(x, y);
    }
  }
}

void mouseDragged() {
  if (newDim) return;
  int x = mouseX / cellSize;
  int y = mouseY / cellSize;
  if (x >= 0 && x < cols && y >= 0 && y < rows) paint(x, y);
}

void paint(int x, int y) {
  if (brushType == 0 || brushType == 5) removeType(brushType);
  grid[x][y] = brushType;
}

void keyPressed() {
  if (newDim) {
    handleDimensionInput();
    return;
  }

  if (key >= '0' && key <= '5') brushType = int(key - '0');
  
  // S: SAVE - Opens native OS window
  if (key == 's' || key == 'S') {
    selectOutput("Save your map as a CSV:", "saveMapFile");
  }
  
  // L: LOAD - Opens native OS window
  if (key == 'l' || key == 'L') {
    selectInput("Select a CSV map to edit:", "loadMapFile");
  }
  
  // N: NEW MAP - Triggers dimension entry mode
  if (key == 'n' || key == 'N') {
    newDim = true;
    dimInput = "";
  }
}

// --- LOGIC FUNCTIONS ---

void handleDimensionInput() {
  if (key == ENTER || key == RETURN) {
    String[] parts = dimInput.split(",");
    if (parts.length == 2) {
      int w = int(parts[0].trim());
      int h = int(parts[1].trim());
      if (w > 0 && h > 0) initMap(w, h);
    }
    newDim = false;
  } else if (key == BACKSPACE && dimInput.length() > 0) {
    dimInput = dimInput.substring(0, dimInput.length() - 1);
  } else if (key >= '0' && key <= '9' || key == ',') {
    dimInput += key;
  }
}

void initMap(int w, int h) {
  cols = w;
  rows = h;
  grid = new int[cols][rows];
  
  surface.setSize(cols * cellSize, rows * cellSize + 100);
  
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      if (x == 0 || x == cols-1 || y == 0 || y == rows-1) grid[x][y] = 2;
      else grid[x][y] = 1;
    }
  }
}

void removeType(int type) {
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      if (grid[x][y] == type) grid[x][y] = 1;
    }
  }
}

// --- FILE CALLBACKS ---

void saveMapFile(File selection) {
  if (selection == null) return;
  String path = selection.getAbsolutePath();
  if (!path.toLowerCase().endsWith(".csv")) path += ".csv";
  
  Table table = new Table();
  for (int x = 0; x < cols; x++) table.addColumn();
  for (int y = 0; y < rows; y++) {
    TableRow newRow = table.addRow();
    for (int x = 0; x < cols; x++) newRow.setInt(x, grid[x][y]);
  }
  saveTable(table, path);
}

void loadMapFile(File selection) {
  if (selection == null) return;
  Table t = loadTable(selection.getAbsolutePath());
  if (t != null) {
    cols = t.getColumnCount();
    rows = t.getRowCount();
    grid = new int[cols][rows];
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        grid[x][y] = t.getInt(y, x);
      }
    }
    surface.setSize(max(600, cols * cellSize), max(400, (rows * cellSize) + 100));
  }
}
