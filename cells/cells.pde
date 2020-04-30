/// All Examples Written by Casey Reas and Ben Fry

// unless otherwise stated.

int numCells = 12;
int numFood = 20;

float spring = 0.05;

PetriDish PD = new PetriDish();

void setup() {
  size(400, 400);
  noStroke();
  smooth();
  for (int i = 0; i < numCells; i++) {
      PD.cells.add(new Cell(random(width), random(height)));
  }
  for (int i = 0; i < numFood; i++) {
      PD.food.add(new Food(random(width), random(height)));
  }
}

void draw() {
  background(0);
  PD.update();
  PD.draw();
}

class Thing {
    float x,y,diameter;
    float vx = 0;
    float vy = 0;
    color c1;
    void update() {
        x += vx;
        y += vy;
        if (x + diameter/2 > width) {
          x = width - diameter/2;
          vx *= -0.9; 
        } else if (x - diameter/2 < 0) {
          x = diameter/2;
          vx *= -0.9;
        } if (y + diameter/2 > height) {
          y = height - diameter/2;
          vy *= -0.9; 
        } else if (y - diameter/2 < 0) {
          y = diameter/2;
          vy *= -0.9;
        }
    }
    float minDist(Thing other) {
        return this.diameter/2.0 + other.diameter/2.0;
    }
    boolean collide(Thing other) {
        float distance = dist(this.x, this.y, other.x, other.y);
        if (distance < this.minDist(other) && distance != 0) {
            return true;
        }
        return false;
    }
    void draw() {
        fill(this.c1);
        ellipse(x, y, diameter, diameter);
    }
}    

class Cell extends Thing {
    int life;
    Cell(float xin, float yin) {
        this.x = xin;
        this.y = yin;
        this.diameter = 20;
        this.vx = random(2);
        this.vy = random(2);
        this.c1 = color(153);
        this.life = int(random(60,300));
    }
    void bounce(ArrayList<Cell> cells) {
        for (Cell cell: cells) {
            if(this.collide(cell)) {
                float angle = atan2(cell.y-this.y, cell.x-this.x);
                float targetX = this.x + cos(angle) * this.minDist(cell);
                float targetY = this.y + sin(angle) * this.minDist(cell);
                float ax = (targetX - cell.x) * spring;
                float ay = (targetY - cell.y) * spring;
                this.vx -= ax;
                this.vy -= ay;
                cell.vx += ax;
                cell.vy += ay;
            }
        }
    }
    int eat(ArrayList<Food> food) {
        for (Food pellet: food) {
           float dx = pellet.x-this.x;
           float dy = pellet.y-this.y;
           float dist = sqrt(dx*dx + dy*dy);
           if (dist < this.diameter/2+pellet.diameter/2) {
               // reset clock
               this.life = 300;
               return food.indexOf(pellet);
           }
        }
        return -1;
    }
    void update() {
        x += vx;
        y += vy;
        if (x + diameter/2 > width) {
          x = width - diameter/2;
          vx *= -0.9; 
        } else if (x - diameter/2 < 0) {
          x = diameter/2;
          vx *= -0.9;
        } if (y + diameter/2 > height) {
          y = height - diameter/2;
          vy *= -0.9; 
        } else if (y - diameter/2 < 0) {
          y = diameter/2;
          vy *= -0.9;
        }
        this.life -= 1;
    }
}

class Food extends Thing {
    Food(float xin, float yin) {
        this.x = xin;
        this.y = yin;
        this.diameter = 10;
        this.c1 = color(204, 102, 0);
    }
}

class PetriDish {
  ArrayList < Cell > cells;
  ArrayList < Food > food;
  PetriDish() {
    // Initialize the bag with an empty ArrayList of balls.
    this.cells = new ArrayList < Cell > ();
    this.food = new ArrayList < Food > ();
  }

  void update() {
    // Update all food and cell.
    // Remove cells that die or are eaten.
    // Spawn new cells that divide.
    for (Cell cell: this.cells) {
        cell.update();
    }
    for (Cell cell: this.cells) {
        cell.bounce(this.cells);
    }
    ArrayList <Cell> tmpList = new ArrayList <Cell> ();
    for (Cell cell: this.cells) {
        int ret = cell.eat(this.food);
        if (ret >= 0) {
            // remove pellet
            food.remove(ret);
            // add new cell
            tmpList.add(new Cell(cell.x+cell.diameter/2, cell.y+cell.diameter/2));
        }
    }
    cells.addAll(tmpList);
    ArrayList<Cell> removeList = new ArrayList<Cell>();
    for (Cell cell: this.cells) {
      if (cell.life <= 0) {
        removeList.add(cell);
      }
    }
    for (Cell cell: removeList) {
      cells.remove(cell);      
    }
    for (Food pellet: this.food) {
        pellet.update();
    }
  }

  void draw() {
    // Iterate over all balls and then draw them
    for (Cell cell: this.cells) {
      cell.draw();
    }
    for (Food pellet: this.food) {
      pellet.draw();
    }
  }
}

