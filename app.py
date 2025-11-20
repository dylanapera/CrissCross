"""
Flask web server for Tic-Tac-Toe game
"""

from flask import Flask, render_template, jsonify, request
from game_logic import TicTacToe

app = Flask(__name__)

# Store game instances (in production, use session management)
games = {}

@app.route('/')
def index():
    """Serve the main game page."""
    return render_template('index.html')

@app.route('/api/new_game', methods=['POST'])
def new_game():
    """Create a new game instance."""
    game_id = request.json.get('game_id', 'default')
    games[game_id] = TicTacToe()
    return jsonify(games[game_id].get_board_state())

@app.route('/api/move', methods=['POST'])
def make_move():
    """Make a move in the game."""
    data = request.json
    game_id = data.get('game_id', 'default')
    row = data.get('row')
    col = data.get('col')
    
    if game_id not in games:
        games[game_id] = TicTacToe()
    
    game = games[game_id]
    success = game.make_move(row, col)
    
    return jsonify({
        'success': success,
        'state': game.get_board_state()
    })

@app.route('/api/state', methods=['GET'])
def get_state():
    """Get current game state."""
    game_id = request.args.get('game_id', 'default')
    
    if game_id not in games:
        games[game_id] = TicTacToe()
    
    return jsonify(games[game_id].get_board_state())

@app.route('/api/reset', methods=['POST'])
def reset_game():
    """Reset the game."""
    game_id = request.json.get('game_id', 'default')
    
    if game_id in games:
        games[game_id].reset_game()
    else:
        games[game_id] = TicTacToe()
    
    return jsonify(games[game_id].get_board_state())

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
