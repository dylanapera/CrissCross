# Tic-Tac-Toe (Knots and Crosses) | [Free to Play](https://aperacrisscross.azurewebsites.net)

A simple web-based Tic-Tac-Toe game built with Python Flask backend and vanilla JavaScript frontend.

## Features

- 🎮 Classic 3x3 Tic-Tac-Toe gameplay
- 🎨 Modern, responsive UI with smooth animations
- 🏆 Win detection for rows, columns, and diagonals
- 🤝 Draw detection when board is full
- 🔄 Reset game functionality
- 📱 Mobile-friendly design

## Project Structure

```
CrissCross/
├── app.py              # Flask web server
├── game_logic.py       # Game logic and rules
├── requirements.txt    # Python dependencies
├── templates/
│   └── index.html     # Main game page
└── static/
    ├── style.css      # Game styling
    └── script.js      # Frontend interactivity
```

## Installation

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

## Running the Game

1. Start the Flask server:
```bash
python app.py
```

2. Open your browser and navigate to:
```
http://localhost:5000
```

## How to Play

1. Player X starts first
2. Click on any empty cell to make your move
3. Players alternate turns (X and O)
4. First player to get 3 in a row (horizontally, vertically, or diagonally) wins
5. If all cells are filled with no winner, it's a draw
6. Click "New Game" to reset and play again

## Game Logic

The game logic is implemented in `game_logic.py` with the following key features:

- **Board Management**: 3x3 grid represented as a 2D list
- **Move Validation**: Ensures moves are legal (empty cell, in bounds)
- **Win Detection**: Checks rows, columns, and diagonals
- **Draw Detection**: Identifies when board is full
- **Turn Management**: Alternates between players automatically

## API Endpoints

- `GET /` - Serve the game page
- `POST /api/new_game` - Create a new game instance
- `POST /api/move` - Make a move (requires row, col)
- `GET /api/state` - Get current game state
- `POST /api/reset` - Reset the current game

## Technologies Used

- **Backend**: Python, Flask
- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Styling**: Modern CSS with gradients and animations

## License

See LICENSE file for details.
