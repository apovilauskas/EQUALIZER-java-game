import processing.sound.*;
int TILE_SIZE = 50;
int currentLevel = 0;
int maxLevels = 3;
final int STATE_START = 0;
final int STATE_PLAYING = 1;
final int STATE_WIN = 2;
final int STATE_PAUSE = 3;
final int STATE_FINISHED = 4;
int gameState = STATE_START;
SoundFile bgMusic;
Table mapTable;
PImage goalImg;
PImage speedImg;
int[][] worldGrid;
int mapRows, mapCols;
Player p;
ArrayList<Enemy> enemies;
ArrayList<Item> items;
PVector goalPos = new PVector(0,0);
float camX, camY;

void setup() {
  size(1200, 800);
  noSmooth();
  try {
    goalImg = loadImage("goal.png");
    speedImg = loadImage("speed.png");
  } catch (Exception e) {
    println("Error loading static images: " + e);
  }
  loadLevel(currentLevel);
}

void draw() {
  background(10);
  if (gameState == STATE_START) {
    drawStartScreen();
  } else if (gameState == STATE_PLAYING) {
    updateGame();
    drawGame();
  } else if (gameState == STATE_WIN) {
    drawGame();
    drawWinScreen();
  } else if (gameState == STATE_PAUSE) {
    drawGame();
    drawPauseScreen();
  } else if (gameState == STATE_FINISHED) {
    drawFinishedScreen();
  }
}

boolean isPointBlocked(float x, float y) {
  int col = int(x / TILE_SIZE);
  int row = int(y / TILE_SIZE);
  if (col < 0 || col >= mapCols || row < 0 || row >= mapRows) return true;
  return (worldGrid[col][row] == 2);
}

void drawStartScreen() {
  textAlign(CENTER, CENTER);
  fill(0, 255, 255);
  textSize(50);
  text("THE EQUALIZER", width/2, height/2 - 150);
  fill(255);
  textSize(16);
  String lorem = "\n\nYou are The Equalizer of the realm. \nThe spirit of rebellion. \nThe folklore legend. \nThe guiding star of the people. \nA thief."+
                 "\n\nUse WASD to move. 'P' to Pause.\n" +
                 "Collect gadgets for speed.\n " +"Reach the diamond to win the level.";
  text(lorem, width/2, height/2 - 50);
  fill(0); stroke(0, 255, 0); rectMode(CENTER);
  rect(width/2, height/2 + 100, 200, 60);
  fill(255); text("START GAME", width/2, height/2 + 100);
  rectMode(CORNER);
}

void drawPauseScreen() {
  fill(0, 150); rectMode(CORNER); rect(0, 0, width, height);
  textAlign(CENTER, CENTER); fill(255, 165, 0); textSize(50);
  text("PAUSED", width/2, height/2 - 50);
  fill(255); textSize(20);
  text("Press SPACE to Continue", width/2, height/2 + 20);
  text("Press Q to Quit Game", width/2, height/2 + 60);
}

void drawWinScreen() {
  fill(0, 150); rect(0, 0, width, height);
  textAlign(CENTER); fill(0, 255, 0); textSize(40);
  text("LEVEL COMPLETE", width/2, height/2);
  fill(255); textSize(20); text("Click to Continue", width/2, height/2 + 50);
}

void drawFinishedScreen() {
  background(20);
  textAlign(CENTER);
  fill(255, 215, 0);
  textSize(50);
  text("YOU WIN", width/2, height/2 - 50);
  fill(255);
  textSize(30);
  text("More levels coming soon.", width/2, height/2 + 20);
}

void loadLevel(int level) {
  if (bgMusic != null) bgMusic.stop();
  try {
    bgMusic = new SoundFile(this, "music" + level + ".mp3");
    bgMusic.loop();
  } catch (Exception e) { println("Music music" + level + ".mp3 missing"); }
  if (level == 0) {
    gameState = STATE_START;
    return;
  }
  enemies = new ArrayList<Enemy>();
  items = new ArrayList<Item>();
  p = null;
  mapTable = loadTable("map" + level + ".csv");
  if (mapTable != null) {
    parseMapFromCSV();
  } else {
    println("Error: map" + level + ".csv not found");
  }
  gameState = STATE_PLAYING;
}

void parseMapFromCSV() {
  mapRows = mapTable.getRowCount();
  mapCols = mapTable.getColumnCount();
  worldGrid = new int[mapCols][mapRows];
  for (int y = 0; y < mapRows; y++) {
    for (int x = 0; x < mapCols; x++) {
      int type = mapTable.getInt(y, x);
      if (type == 0) {
        p = new Player(x * TILE_SIZE, y * TILE_SIZE);
        worldGrid[x][y] = 1;
      } else if (type == 3) {
        enemies.add(new Enemy(x * TILE_SIZE, y * TILE_SIZE));
        worldGrid[x][y] = 1;
      } else if (type == 4) {
        items.add(new Item(x * TILE_SIZE, y * TILE_SIZE, 4));
        worldGrid[x][y] = 1;
      } else if (type == 5) {
        goalPos = new PVector(x * TILE_SIZE, y * TILE_SIZE);
        worldGrid[x][y] = 1;
      } else {
        worldGrid[x][y] = type;
      }
    }
  }
  if (p == null) p = new Player(100, 100);
}

void updateGame() {
  p.update();
  if (dist(p.pos.x, p.pos.y, goalPos.x + TILE_SIZE/2, goalPos.y + TILE_SIZE/2) < TILE_SIZE/2) {
    gameState = STATE_WIN;
  }
  for (Enemy e : enemies) {
    e.update();
    if (dist(p.pos.x, p.pos.y, e.pos.x, e.pos.y) < 40) {
      loadLevel(currentLevel);
    }
  }
  for (int i = items.size()-1; i >= 0; i--) {
    if (dist(p.pos.x, p.pos.y, items.get(i).pos.x, items.get(i).pos.y) < TILE_SIZE) {
      p.speed += 0.7;
      items.remove(i);
    }
  }
  camX = lerp(camX, constrain(p.pos.x - width/2, 0, (mapCols * TILE_SIZE) - width), 0.1);
  camY = lerp(camY, constrain(p.pos.y - height/2, 0, (mapRows * TILE_SIZE) - height), 0.1);
}

void drawGame() {
  pushMatrix();
  translate(-camX, -camY);
  for (int x = 0; x < mapCols; x++) {
    for (int y = 0; y < mapRows; y++) {
      if (worldGrid[x][y] == 2) {
        fill(255, 20, 147);
        stroke(255, 255, 0);
        strokeWeight(2);
        rect(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
      } else {
        fill(0);
        noStroke();
        rect(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
      }
    }
  }
  imageMode(CENTER);
  if (goalImg != null) {
    image(goalImg, goalPos.x + TILE_SIZE/2, goalPos.y + TILE_SIZE/2, 50, 50);
  } else {
    noFill(); stroke(255, 255, 0); ellipse(goalPos.x + TILE_SIZE/2, goalPos.y + TILE_SIZE/2, 40, 40);
  }
  for (Item item : items) item.display();
  for (Enemy e : enemies) e.display();
  p.display();
  popMatrix();
}

void mousePressed() {
  if (gameState == STATE_START) {
     if (mouseX > width/2 - 100 && mouseX < width/2 + 100 && mouseY > height/2 + 70 && mouseY < height/2 + 130) {
       currentLevel = 1;
       loadLevel(currentLevel);
     }
  } else if (gameState == STATE_WIN) {
    currentLevel++;
    if (currentLevel >= maxLevels) {
       gameState = STATE_FINISHED;
    } else {
       loadLevel(currentLevel);
    }
  }
}

void keyPressed() {
  if (gameState == STATE_PLAYING) {
    if (key == 'p' || key == 'P') gameState = STATE_PAUSE;
  } else if (gameState == STATE_PAUSE) {
    if (key == ' ') gameState = STATE_PLAYING;
    if (key == 'q' || key == 'Q') exit();
  }
}

class Player {
  PVector pos;
  float speed = 4.0;
  String dir = "neutral";
  PImage[] frames = new PImage[2];
  int currentFrame = 0;
  float halfW = 19;
  float halfH = 19;

  Player(float x, float y) {
    pos = new PVector(x + TILE_SIZE/2, y + TILE_SIZE/2);
    updateSprites("neutral");
  }

  void updateSprites(String newDir) {
    if (!dir.equals(newDir) || frames[0] == null) {
      dir = newDir;
      try {
        frames[0] = loadImage(dir + "1.png");
        frames[1] = loadImage(dir + "2.png");
      } catch (Exception e) {
        println("Missing player sprite: " + dir);
      }
    }
  }

  void update() {
    float dx = 0, dy = 0;
    String newDir = "neutral";
    if (mousePressed && gameState == STATE_PLAYING) {
      float worldMouseX = mouseX + camX;
      float worldMouseY = mouseY + camY;
      PVector toMouse = new PVector(worldMouseX - pos.x, worldMouseY - pos.y);
      if (toMouse.mag() > 5) {
        toMouse.normalize();
        toMouse.mult(speed);
        dx = toMouse.x;
        dy = toMouse.y;
        if (abs(dx) > abs(dy)) {
          newDir = (dx > 0) ? "playerright" : "playerleft";
        } else {
          newDir = (dy > 0) ? "playerdown" : "playerup";
        }
      }
    }
    updateSprites(newDir);
    float nextX = pos.x + dx;
    if (!isPointBlocked(nextX - halfW, pos.y - halfH) &&
        !isPointBlocked(nextX + halfW, pos.y - halfH) &&
        !isPointBlocked(nextX - halfW, pos.y + halfH) &&
        !isPointBlocked(nextX + halfW, pos.y + halfH)) {
        pos.x = nextX;
    }
    float nextY = pos.y + dy;
    if (!isPointBlocked(pos.x - halfW, nextY - halfH) &&
        !isPointBlocked(pos.x + halfW, nextY - halfH) &&
        !isPointBlocked(pos.x - halfW, nextY + halfH) &&
        !isPointBlocked(pos.x + halfW, nextY + halfH)) {
        pos.y = nextY;
    }
    if (dx != 0 || dy != 0) {
      if (frameCount % 12 == 0) currentFrame = (currentFrame + 1) % 2;
    }
  }

  void display() {
    imageMode(CENTER);
    if (frames[currentFrame] != null) image(frames[currentFrame], pos.x, pos.y, 50, 50);
    else rect(pos.x-20, pos.y-20, 40, 40);
  }
}

class Enemy {
  PVector pos, vel;
  String dir = "neutral";
  PImage[] frames = new PImage[2];
  int currentFrame = 0;
  float halfW = 19;
  float halfH = 19;

  Enemy(float x, float y) {
    pos = new PVector(x + TILE_SIZE/2, y + TILE_SIZE/2);
    vel = new PVector(3, 0);
    updateSprites("enemyright");
  }

  void updateSprites(String newDir) {
    if (!dir.equals(newDir) || frames[0] == null) {
      dir = newDir;
      try {
        frames[0] = loadImage(dir + "1.png");
        frames[1] = loadImage(dir + "2.png");
      } catch (Exception e) {
        println("Missing enemy sprite: " + dir);
      }
    }
  }

  void update() {
    String newDir = "neutral";
    if (vel.x > 0) newDir = "enemyright";
    else if (vel.x < 0) newDir = "enemyleft";
    else if (vel.y > 0) newDir = "enemydown";
    else if (vel.y < 0) newDir = "enemyup";
    updateSprites(newDir);
    float nextX = pos.x + vel.x;
    boolean colX = isPointBlocked(nextX - halfW, pos.y - halfH) ||
                   isPointBlocked(nextX + halfW, pos.y - halfH) ||
                   isPointBlocked(nextX - halfW, pos.y + halfH) ||
                   isPointBlocked(nextX + halfW, pos.y + halfH);
    if (colX) {
      vel.x *= -1;
      float temp = vel.x; vel.x = -vel.y; vel.y = temp;
    } else {
      pos.x = nextX;
    }
    float nextY = pos.y + vel.y;
    boolean colY = isPointBlocked(pos.x - halfW, nextY - halfH) ||
                   isPointBlocked(pos.x + halfW, nextY - halfH) ||
                   isPointBlocked(pos.x - halfW, nextY + halfH) ||
                   isPointBlocked(pos.x + halfW, nextY + halfH);
    if (colY) {
       float temp = vel.y; vel.y = -vel.x; vel.x = temp;
    } else {
      pos.y = nextY;
    }
    if (frameCount % 27 == 0) currentFrame = (currentFrame + 1) % 2;
  }

  void display() {
    imageMode(CENTER);
    if (frames[currentFrame] != null) image(frames[currentFrame], pos.x, pos.y, 60, 60);
    else { fill(255,0,0); rect(pos.x-20, pos.y-20, 50, 50); }
  }
}

class Item {
  PVector pos; int type;
  Item(float x, float y, int t) { pos = new PVector(x + TILE_SIZE/2, y + TILE_SIZE/2); type = t; }
  void display() {
    imageMode(CENTER);
    if (speedImg != null) {
      image(speedImg, pos.x, pos.y, 40, 40);
    } else {
      stroke(0, 150, 255); noFill(); triangle(pos.x, pos.y-10, pos.x-10, pos.y+10, pos.x+10, pos.y+10);
    }
  }
}
