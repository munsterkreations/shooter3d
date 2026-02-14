require 'opengl'
require 'glu'
require 'glut'

include Gl
include Glu
include Glut

class SpaceShooter3D
  WINDOW_WIDTH = 800
  WINDOW_HEIGHT = 600

  def initialize
    @score = 0
    @health = 100
    @player_x = 0.0
    @player_y = 0.0
    @player_z = 0.0
    @bullets = []
    @enemies = []
    @keys = {}
    @last_shot_time = 0
    @last_enemy_spawn = 0
    @rotation = 0.0

    setup_glut
    setup_opengl
  end

  def setup_glut
    glutInit
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH)
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT)
    glutInitWindowPosition(100, 100)
    glutCreateWindow("3D Space Shooter - Ruby OpenGL")

    glutDisplayFunc(method(:display).to_proc)
    glutReshapeFunc(method(:reshape).to_proc)
    glutIdleFunc(method(:idle).to_proc)
    glutKeyboardFunc(method(:keyboard).to_proc)
    glutKeyboardUpFunc(method(:keyboard_up).to_proc)
    glutSpecialFunc(method(:special_keys).to_proc)
    glutSpecialUpFunc(method(:special_keys_up).to_proc)
  end

  def setup_opengl
    glClearColor(0.0, 0.0, 0.1, 1.0)
    glEnable(GL_DEPTH_TEST)
    glEnable(GL_LIGHTING)
    glEnable(GL_LIGHT0)
    glEnable(GL_COLOR_MATERIAL)
    glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE)

    # Setup lighting
    light_position = [5.0, 10.0, 10.0, 1.0]
    light_ambient = [0.3, 0.3, 0.3, 1.0]
    light_diffuse = [1.0, 1.0, 1.0, 1.0]

    glLightfv(GL_LIGHT0, GL_POSITION, light_position)
    glLightfv(GL_LIGHT0, GL_AMBIENT, light_ambient)
    glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse)

    puts "=== 3D Space Shooter ==="
    puts "Controls:"
    puts "  Arrow Keys - Move"
    puts "  Space - Shoot"
    puts "  ESC - Quit"
    puts ""
    puts "Score: #{@score} | Health: #{@health}"
  end

  def reshape(width, height)
    height = 1 if height == 0
    glViewport(0, 0, width, height)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    gluPerspective(45.0, width.to_f / height.to_f, 0.1, 100.0)
    glMatrixMode(GL_MODELVIEW)
  end

  def draw_player
    glPushMatrix
    glTranslatef(@player_x, @player_y, @player_z)
    glRotatef(-90, 1, 0, 0)

    # Main body (green)
    glColor3f(0.0, 1.0, 0.0)
    glutSolidCone(0.5, 2.0, 12, 12)

    # Cockpit (cyan)
    glPushMatrix
    glTranslatef(0, 0, 1.5)
    glColor3f(0.0, 1.0, 1.0)
    glutSolidSphere(0.3, 10, 10)
    glPopMatrix

    # Wings
    glColor3f(0.0, 0.7, 0.0)
    
    # Left wing
    glPushMatrix
    glTranslatef(-1.5, 0, 0.5)
    glScalef(2.0, 0.1, 0.8)
    glutSolidCube(1.0)
    glPopMatrix

    # Right wing
    glPushMatrix
    glTranslatef(1.5, 0, 0.5)
    glScalef(2.0, 0.1, 0.8)
    glutSolidCube(1.0)
    glPopMatrix

    # Engine glow (orange)
    glColor3f(1.0, 0.5, 0.0)
    [-0.4, 0.4].each do |x_offset|
      glPushMatrix
      glTranslatef(x_offset, 0, -0.5)
      glutSolidSphere(0.15, 8, 8)
      glPopMatrix
    end

    glPopMatrix
  end

  def draw_bullet(bullet)
    glPushMatrix
    glTranslatef(bullet[:x], bullet[:y], bullet[:z])
    glColor3f(1.0, 1.0, 0.0)
    glutSolidSphere(0.15, 8, 8)
    glPopMatrix
  end

  def draw_enemy(enemy)
    glPushMatrix
    glTranslatef(enemy[:x], enemy[:y], enemy[:z])
    glRotatef(@rotation * 2, 0, 1, 0)
    glRotatef(90, 1, 0, 0)

    # Enemy body (red)
    glColor3f(1.0, 0.0, 0.0)
    glutSolidCone(0.4, 1.5, 10, 10)

    # Enemy wings (dark red)
    glColor3f(0.7, 0.0, 0.0)
    
    glPushMatrix
    glTranslatef(0, 0, 0.5)
    glScalef(1.5, 0.1, 0.6)
    glutSolidCube(1.0)
    glPopMatrix

    glPopMatrix
  end

  def draw_starfield
    glDisable(GL_LIGHTING)
    glColor3f(1.0, 1.0, 1.0)
    glPointSize(2.0)
    glBegin(GL_POINTS)
    
    100.times do |i|
      x = (i * 37 % 200 - 100) / 10.0
      y = (i * 73 % 200 - 100) / 10.0
      z = -50 + (i * 17 % 100) / 2.0
      glVertex3f(x, y, z)
    end
    
    glEnd
    glEnable(GL_LIGHTING)
  end

  def display
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glLoadIdentity

    # Camera position
    gluLookAt(0, 3, 15, 0, 0, 0, 0, 1, 0)

    draw_starfield
    draw_player

    @bullets.each { |bullet| draw_bullet(bullet) }
    @enemies.each { |enemy| draw_enemy(enemy) }

    glutSwapBuffers
  end

  def update_game
    current_time = Time.now.to_f

    # Update player movement
    speed = 0.3
    @player_x -= speed if @keys[:left]
    @player_x += speed if @keys[:right]
    @player_y += speed if @keys[:up]
    @player_y -= speed if @keys[:down]

    # Constrain player
    @player_x = [[-8, @player_x].max, 8].min
    @player_y = [[-4, @player_y].max, 4].min

    # Shoot
    if @keys[:space] && (current_time - @last_shot_time) > 0.2
      @bullets << { x: @player_x, y: @player_y, z: @player_z - 1.5 }
      @last_shot_time = current_time
    end

    # Update bullets
    @bullets.each { |b| b[:z] -= 1.0 }
    @bullets.reject! { |b| b[:z] < -50 }

    # Spawn enemies
    if (current_time - @last_enemy_spawn) > 2.0 && @enemies.length < 5
      @enemies << {
        x: (rand - 0.5) * 15,
        y: (rand - 0.5) * 8,
        z: -40
      }
      @last_enemy_spawn = current_time
    end

    # Update enemies
    @enemies.each { |e| e[:z] += 0.2 }
    @enemies.reject! { |e| e[:z] > 20 }

    # Check collisions
    check_collisions

    @rotation += 1.0
  end

  def check_collisions
    # Bullets vs Enemies
    @bullets.each do |bullet|
      @enemies.each do |enemy|
        dx = bullet[:x] - enemy[:x]
        dy = bullet[:y] - enemy[:y]
        dz = bullet[:z] - enemy[:z]
        distance = Math.sqrt(dx*dx + dy*dy + dz*dz)

        if distance < 1.5
          @bullets.delete(bullet)
          @enemies.delete(enemy)
          @score += 10
          puts "Score: #{@score} | Health: #{@health}"
          break
        end
      end
    end

    # Enemies vs Player
    @enemies.each do |enemy|
      dx = @player_x - enemy[:x]
      dy = @player_y - enemy[:y]
      dz = @player_z - enemy[:z]
      distance = Math.sqrt(dx*dx + dy*dy + dz*dz)

      if distance < 1.5
        @enemies.delete(enemy)
        @health -= 10
        puts "HIT! Score: #{@score} | Health: #{@health}"
        
        if @health <= 0
          puts "\n=== GAME OVER ==="
          puts "Final Score: #{@score}"
          exit
        end
      end
    end
  end

  def idle
    update_game
    glutPostRedisplay
  end

  def keyboard(key, x, y)
    case key
    when 27  # ESC
      exit
    when 32  # Space
      @keys[:space] = true
    end
  end

  def keyboard_up(key, x, y)
    @keys[:space] = false if key == 32
  end

  def special_keys(key, x, y)
    @keys[:left] = true if key == GLUT_KEY_LEFT
    @keys[:right] = true if key == GLUT_KEY_RIGHT
    @keys[:up] = true if key == GLUT_KEY_UP
    @keys[:down] = true if key == GLUT_KEY_DOWN
  end

  def special_keys_up(key, x, y)
    @keys[:left] = false if key == GLUT_KEY_LEFT
    @keys[:right] = false if key == GLUT_KEY_RIGHT
    @keys[:up] = false if key == GLUT_KEY_UP
    @keys[:down] = false if key == GLUT_KEY_DOWN
  end

  def run
    glutMainLoop
  end
end

# Run the game
if __FILE__ == $0
  game = SpaceShooter3D.new
  game.run
end
