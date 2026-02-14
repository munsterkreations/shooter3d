require 'mittsu'

class SpaceShooterGame
  SCREEN_WIDTH = 800
  SCREEN_HEIGHT = 600

  def initialize
    @scene = Mittsu::Scene.new
    @camera = Mittsu::PerspectiveCamera.new(75.0, SCREEN_WIDTH.to_f / SCREEN_HEIGHT.to_f, 0.1, 1000.0)
    
    @renderer = Mittsu::OpenGLRenderer.new(
      width: SCREEN_WIDTH, 
      height: SCREEN_HEIGHT, 
      title: '3D Space Shooter'
    )

    @score = 0
    @health = 100
    @bullets = []
    @enemies = []
    @keys = {}
    
    @player_speed = 0.3
    @bullet_speed = 1.0
    @enemy_speed = 0.2
    @last_shot_time = 0
    @shot_cooldown = 0.2
    @last_enemy_spawn = 0
    @enemy_spawn_interval = 2.0

    setup_scene
    setup_lighting
    load_models
    setup_input
  end

  def setup_scene
    # Set camera position
    @camera.position.z = 15
    @camera.position.y = 3

    # Add starfield background
    create_starfield

    # Create player group
    @player_group = Mittsu::Group.new
    @scene.add(@player_group)
  end

  def setup_lighting
    # Ambient light
    ambient = Mittsu::AmbientLight.new(0x404040)
    @scene.add(ambient)

    # Directional light
    directional = Mittsu::DirectionalLight.new(0xffffff, 1.0)
    directional.position.set(5, 10, 7.5)
    @scene.add(directional)

    # Point light for dramatic effect
    @point_light = Mittsu::PointLight.new(0x4444ff, 1.0, 50.0)
    @point_light.position.set(0, 5, 0)
    @scene.add(@point_light)
  end

  def create_starfield
    star_geometry = Mittsu::Geometry.new
    1000.times do
      vertex = Mittsu::Vector3.new(
        (rand - 0.5) * 200,
        (rand - 0.5) * 200,
        (rand - 0.5) * 200
      )
      star_geometry.vertices << vertex
    end

    star_material = Mittsu::PointCloudMaterial.new(color: 0xffffff, size: 0.5)
    @stars = Mittsu::PointCloud.new(star_geometry, star_material)
    @scene.add(@stars)
  end

  def load_models
    # Try to load FBX models, fallback to simple geometry
    begin
      load_player_model
    rescue => e
      puts "Could not load player FBX model: #{e.message}"
      puts "Using fallback geometry for player"
      create_fallback_player
    end

    begin
      load_enemy_template
    rescue => e
      puts "Could not load enemy FBX model: #{e.message}"
      puts "Using fallback geometry for enemies"
      create_fallback_enemy_template
    end
  end

  def load_player_model
    # Mittsu doesn't have built-in FBX loader, so we'll use OBJ or create geometry
    # For now, create a detailed player ship from primitives
    create_player_ship
  end

  def create_player_ship
    # Main body (cone for ship)
    body_geometry = Mittsu::CylinderGeometry.new(0.3, 0.8, 2.0, 8)
    body_material = Mittsu::MeshPhongMaterial.new(color: 0x00ff00, shininess: 30)
    body = Mittsu::Mesh.new(body_geometry, body_material)
    body.rotation.x = Math::PI / 2
    @player_group.add(body)

    # Cockpit
    cockpit_geometry = Mittsu::SphereGeometry.new(0.4, 8, 8)
    cockpit_material = Mittsu::MeshPhongMaterial.new(color: 0x00ffff, transparent: true, opacity: 0.7)
    cockpit = Mittsu::Mesh.new(cockpit_geometry, cockpit_material)
    cockpit.position.z = 0.5
    @player_group.add(cockpit)

    # Wings
    wing_geometry = Mittsu::BoxGeometry.new(3.0, 0.1, 1.0)
    wing_material = Mittsu::MeshPhongMaterial.new(color: 0x00aa00)
    wings = Mittsu::Mesh.new(wing_geometry, wing_material)
    wings.position.z = -0.3
    @player_group.add(wings)

    # Engine glow
    engine_geometry = Mittsu::SphereGeometry.new(0.2, 8, 8)
    engine_material = Mittsu::MeshBasicMaterial.new(color: 0xff4400)
    
    [-0.5, 0.5].each do |x_pos|
      engine = Mittsu::Mesh.new(engine_geometry, engine_material)
      engine.position.set(x_pos, 0, -1.0)
      @player_group.add(engine)
    end

    @player = @player_group
    puts "Player ship created successfully"
  end

  def load_enemy_template
    create_enemy_ship_template
  end

  def create_enemy_ship_template
    enemy_group = Mittsu::Group.new

    # Enemy body (inverted cone)
    body_geometry = Mittsu::ConeGeometry.new(0.5, 1.5, 8)
    body_material = Mittsu::MeshPhongMaterial.new(color: 0xff0000, shininess: 30)
    body = Mittsu::Mesh.new(body_geometry, body_material)
    body.rotation.x = -Math::PI / 2
    enemy_group.add(body)

    # Enemy wings
    wing_geometry = Mittsu::BoxGeometry.new(2.0, 0.1, 0.8)
    wing_material = Mittsu::MeshPhongMaterial.new(color: 0xaa0000)
    wings = Mittsu::Mesh.new(wing_geometry, wing_material)
    wings.position.z = 0.2
    enemy_group.add(wings)

    @enemy_template = enemy_group
    puts "Enemy ship template created successfully"
  end

  def create_fallback_player
    geometry = Mittsu::ConeGeometry.new(0.5, 2.0, 8)
    material = Mittsu::MeshPhongMaterial.new(color: 0x00ff00)
    mesh = Mittsu::Mesh.new(geometry, material)
    mesh.rotation.x = Math::PI / 2
    @player_group.add(mesh)
    @player = @player_group
  end

  def create_fallback_enemy_template
    geometry = Mittsu::ConeGeometry.new(0.4, 1.5, 8)
    material = Mittsu::MeshPhongMaterial.new(color: 0xff0000)
    @enemy_template = Mittsu::Mesh.new(geometry, material)
    @enemy_template.rotation.x = -Math::PI / 2
  end

  def setup_input
    @renderer.window.on_key_pressed do |key|
      @keys[key] = true
    end

    @renderer.window.on_key_released do |key|
      @keys[key] = false
    end
  end

  def shoot_bullet
    current_time = Time.now.to_f
    return if current_time - @last_shot_time < @shot_cooldown

    bullet_geometry = Mittsu::SphereGeometry.new(0.15, 8, 8)
    bullet_material = Mittsu::MeshBasicMaterial.new(color: 0xffff00)
    bullet = Mittsu::Mesh.new(bullet_geometry, bullet_material)
    
    bullet.position.copy(@player_group.position)
    bullet.position.z -= 1.5
    
    @scene.add(bullet)
    @bullets << bullet
    @last_shot_time = current_time
  end

  def spawn_enemy
    return if @enemies.length >= 5

    enemy = @enemy_template.clone
    enemy.position.set(
      (rand - 0.5) * 15,
      (rand - 0.5) * 8,
      -40
    )
    enemy.user_data = { health: 1 }
    
    @scene.add(enemy)
    @enemies << enemy
  end

  def update_player(delta_time)
    # Movement
    if @keys[GLFW::KEY_LEFT] || @keys[GLFW::KEY_A]
      @player_group.position.x -= @player_speed
    end
    if @keys[GLFW::KEY_RIGHT] || @keys[GLFW::KEY_D]
      @player_group.position.x += @player_speed
    end
    if @keys[GLFW::KEY_UP] || @keys[GLFW::KEY_W]
      @player_group.position.y += @player_speed
    end
    if @keys[GLFW::KEY_DOWN] || @keys[GLFW::KEY_S]
      @player_group.position.y -= @player_speed
    end

    # Shooting
    if @keys[GLFW::KEY_SPACE]
      shoot_bullet
    end

    # Constrain player position
    @player_group.position.x = [[-8, @player_group.position.x].max, 8].min
    @player_group.position.y = [[-4, @player_group.position.y].max, 4].min

    # Slight rotation for visual effect
    @player_group.rotation.z = -@player_group.position.x * 0.1
  end

  def update_bullets(delta_time)
    @bullets.each do |bullet|
      bullet.position.z -= @bullet_speed
    end

    # Remove off-screen bullets
    @bullets.reject! do |bullet|
      if bullet.position.z < -50
        @scene.remove(bullet)
        true
      else
        false
      end
    end
  end

  def update_enemies(delta_time)
    @enemies.each do |enemy|
      enemy.position.z += @enemy_speed
      enemy.rotation.y += 0.02
    end

    # Remove off-screen enemies
    @enemies.reject! do |enemy|
      if enemy.position.z > 20
        @scene.remove(enemy)
        true
      else
        false
      end
    end
  end

  def check_collisions
    # Bullets vs Enemies
    @bullets.each do |bullet|
      @enemies.each do |enemy|
        distance = bullet.position.distance_to(enemy.position)
        if distance < 1.5
          @scene.remove(bullet)
          @bullets.delete(bullet)
          @scene.remove(enemy)
          @enemies.delete(enemy)
          @score += 10
          puts "Score: #{@score}"
          break
        end
      end
    end

    # Enemies vs Player
    @enemies.each do |enemy|
      distance = @player_group.position.distance_to(enemy.position)
      if distance < 1.5
        @scene.remove(enemy)
        @enemies.delete(enemy)
        @health -= 10
        puts "Health: #{@health}"
        if @health <= 0
          puts "Game Over! Final Score: #{@score}"
          exit
        end
      end
    end
  end

  def update(delta_time)
    current_time = Time.now.to_f

    update_player(delta_time)
    update_bullets(delta_time)
    update_enemies(delta_time)
    check_collisions

    # Spawn enemies periodically
    if current_time - @last_enemy_spawn > @enemy_spawn_interval
      spawn_enemy
      @last_enemy_spawn = current_time
    end

    # Rotate starfield
    @stars.rotation.y += 0.0002

    # Animate point light
    @point_light.intensity = 1.0 + Math.sin(current_time * 2) * 0.3
  end

  def run
    puts "=== 3D Space Shooter ==="
    puts "Controls:"
    puts "  Arrow Keys / WASD - Move"
    puts "  Space - Shoot"
    puts "  ESC - Quit"
    puts ""
    puts "Starting game..."

    last_time = Time.now.to_f

    @renderer.window.run do
      current_time = Time.now.to_f
      delta_time = current_time - last_time
      last_time = current_time

      update(delta_time)
      @renderer.render(@scene, @camera)
    end
  end
end

# Run the game
if __FILE__ == $0
  game = SpaceShooterGame.new
  game.run
end