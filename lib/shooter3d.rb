
require 'gosu'
require 'opengl'
include OpenGL

class GameWindow < Gosu::Window
  def initialize
    super(640, 480)
    self.caption = "3D Space Shooting Game"

    # OpenGL setup
    glEnable(GL_DEPTH_TEST) # Enable depth testing
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    gluPerspective(45.0, width.to_f / height.to_f, 1.0, 1000.0)

    @player = Player.new
    @bullets = []
    @enemies = []
    @power_ups = []
    @score = 0
    @font = Gosu::Font.new(20)
  end

  def update
    # Handle player movement
    @player.move_left if Gosu.button_down? Gosu::KB_LEFT
    @player.move_right if Gosu.button_down? Gosu::KB_RIGHT
    @player.move_up if Gosu.button_down? Gosu::KB_UP
    @player.move_down if Gosu.button_down? Gosu::KB_DOWN
    @player.shoot(@bullets) if Gosu.button_down? Gosu::KB_SPACE

    # Update bullets and check collisions
    @bullets.each(&:move)
    @bullets.reject! { |bullet| bullet.off_screen? }

    # Spawn enemies
    @enemies.push(Enemy.new) if rand(100) < 4 && @enemies.size < 5
    @enemies.each(&:move)

    # Check collisions between bullets and enemies
    @bullets.each do |bullet|
      @enemies.each do |enemy|
        if enemy.collide?(bullet)
          @score += 10
          @enemies.delete(enemy)
          @bullets.delete(bullet)
          break
        end
      end
    end

    # Check collisions between player and enemies
    @enemies.each do |enemy|
      if enemy.collide?(@player)
        reset_game
        break
      end
    end
  end

  def draw
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
    gluLookAt(0, 0, 400, 0, 0, 0, 0, 1, 0) # Camera position

    # Draw objects
    @player.draw
    @bullets.each(&:draw)
    @enemies.each(&:draw)

    # Display score
    glDisable(GL_DEPTH_TEST)
    @font.draw_text("Score: #{@score}", 10, 10, 1, 1.0, 1.0, Gosu::Color::WHITE)
    glEnable(GL_DEPTH_TEST)
  end

  def reset_game
    initialize
  end
end

class Player
  attr_reader :x, :y, :z

  def initialize
    @x = @y = 0
    @z = 0
    @size = 20
  end

  def move_left
    @x -= 5
  end

  def move_right
    @x += 5
  end

  def move_up
    @y += 5
  end

  def move_down
    @y -= 5
  end

  def shoot(bullets)
    bullets.push(Bullet.new(@x, @y, @z - 10))
  end

  def draw
    glPushMatrix
    glTranslate(@x, @y, @z)
    glColor3f(0.0, 1.0, 0.0)
    glutSolidCube(@size)
    glPopMatrix
  end
end

class Bullet
  attr_reader :x, :y, :z

  def initialize(x, y, z)
    @x, @y, @z = x, y, z
    @speed = 10
  end

  def move
    @z -= @speed
  end

  def off_screen?
    @z < -400
  end

  def draw
    glPushMatrix
    glTranslate(@x, @y, @z)
    glColor3f(1.0, 1.0, 0.0)
    glutSolidSphere(5, 10, 10)
    glPopMatrix
  end
end

class Enemy
  attr_reader :x, :y, :z

  def initialize
    @x = rand(-300..300)
    @y = rand(-200..200)
    @z = 300
    @size = 30
  end

  def move
    @z -= 5
  end

  def collide?(object)
    Gosu.distance(object.x, object.y, @x, @y) < 30 && (@z - object.z).abs < 30
  end

  def draw
    glPushMatrix
    glTranslate(@x, @y, @z)
    glColor3f(1.0, 0.0, 0.0)
    glutSolidCube(@size)
    glPopMatrix
  end
end

# Start the game
window = GameWindow.new
window.show
