# Quick Start Guide

## Fastest Way to Play (No Setup Required!)

### Option 1: Ruby OpenGL Version (Recommended)
```bash
# Install OpenGL gems (one-time setup)
gem install opengl glu glut

# Run the game
ruby shooter_3d_opengl.rb
```

**Controls:**
- Arrow Keys: Move your ship
- Space: Shoot
- ESC: Quit

This version works immediately with no external assets needed!

---

### Option 2: Web Browser Version
```bash
# Just open the file in your browser
# Double-click: game.html

# Or use a local server for best performance:
python -m http.server 8000
# Then visit: http://localhost:8000/game.html
```

**Controls:**
- Arrow Keys or WASD: Move
- Space: Shoot
- Mouse: Look around

---

## Advanced Options

### Mittsu 3D Version (More Features)
```bash
# Install mittsu gem
gem install mittsu

# Run the game
ruby shooter_3d.rb
```

### Install All Dependencies
```bash
# Run the setup script
./Bin/setup

# Or manually:
bundle install
```

---

## Troubleshooting

### OpenGL Version Issues
If you get errors about missing OpenGL:

**Windows:**
```bash
gem install opengl glu glut
```

**macOS:**
```bash
gem install opengl glu glut
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install freeglut3-dev
gem install opengl glu glut
```

### Mittsu Version Issues
If mittsu doesn't install:
```bash
# Try installing dependencies first
gem install glfw3
gem install mittsu
```

### Web Version Issues
If game.html doesn't load models:
- Make sure you're viewing from a web server (not file://)
- Check browser console for errors
- Verify FBX files exist in assets/ folders

---

## Game Features

- **3D Graphics**: Real-time 3D rendering with lighting
- **Score System**: Earn points by destroying enemies
- **Health System**: Take damage when hit by enemies
- **Dynamic Spawning**: Enemies spawn continuously
- **Smooth Controls**: Responsive keyboard controls
- **Visual Effects**: Engine glow, starfield, lighting effects

---

## Which Version Should I Use?

| Version | Pros | Cons |
|---------|------|------|
| **shooter_3d_opengl.rb** | ✓ No assets needed<br>✓ Fast<br>✓ Simple setup | - Basic graphics |
| **game.html** | ✓ Uses FBX models<br>✓ Best graphics<br>✓ No Ruby needed | - Needs web server |
| **shooter_3d.rb** | ✓ Ruby native<br>✓ Good graphics | - Requires mittsu gem |

**Recommendation:** Start with `shooter_3d_opengl.rb` for Q
