# Shooter3D - Space Shooting Game

A space shooting game project with multiple implementations.

## Quick Start - Play Now! 🚀

**Fastest Option (No Assets Needed):**
```bash
gem install opengl glu glut
ruby shooter_3d_opengl.rb
```

**Web Version:** Open `game.html` in your browser to play with FBX models.

See [QUICKSTART.md](QUICKSTART.md) for detailed instructions.

**Controls:**
- Arrow Keys or WASD: Move your ship
- Space: Shoot
- ESC/Mouse: Quit/Look around

## Project Structure

### Web-Based Games
- **game.html** - 3D space shooter using Three.js with FBX models ⭐ NEW
- **index.html** - 2D web game client (requires WebSocket server)

### Desktop Games (Ruby)
- **shooter_3d_opengl.rb** - 3D game using Ruby OpenGL/GLUT ⭐ NEW (works immediately!)
- **shooter_3d.rb** - 3D game using Mittsu library ⭐ NEW (requires mittsu gem)
- **shooter.rb** - 2D desktop game using Gosu (requires PNG assets)
- **lib/jekyll.rb** - 3D desktop game with OpenGL (requires PNG assets)

## Available 3D Models

The project includes professional FBX 3D models:
- Player ships: `assets/player/Destroyer_01.fbx`, `Destroyer_04.fbx`
- Enemy ships: `assets/enemy/Corvette_03.fbx`, `Corvette_04.fbx`
- Additional ships in root directory

## Setup for Ruby Desktop Versions

### Prerequisites
- Ruby 3.0.0 or higher
- Bundler

### Installation

```bash
# Run the setup script
./Bin/setup

# Or manually:
bundle install
```

### Running Desktop Games

```bash
# 3D OpenGL Game (Recommended - No assets needed!)
ruby shooter_3d_opengl.rb

# 3D Mittsu Game (Requires: gem install mittsu)
ruby shooter_3d.rb

# 2D Gosu Game (Requires PNG assets)
ruby shooter.rb

# Original 3D Game (Requires PNG assets)
ruby lib/jekyll.rb
```

**Note:** 
- `shooter_3d_opengl.rb` works immediately with no external assets
- `shooter_3d.rb` requires the mittsu gem: `gem install mittsu`
- Other versions require PNG image assets. See ASSETS_NEEDED.md for details.

## Features

- 3D graphics with real spaceship models
- Score tracking
- Health system
- Dynamic enemy spawning
- Smooth controls
- Starfield background
- Collision detection

## License

MIT

