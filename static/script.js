// Game state management
const gameId = 'default';
let currentState = null;

// DOM elements
const cells = document.querySelectorAll('.cell');
const statusDiv = document.getElementById('status');
const resetBtn = document.getElementById('resetBtn');

// Initialize game
async function initGame() {
    try {
        const response = await fetch('/api/new_game', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ game_id: gameId })
        });
        
        const data = await response.json();
        updateUI(data);
    } catch (error) {
        console.error('Error initializing game:', error);
        statusDiv.textContent = 'Error connecting to server';
    }
}

// Make a move
async function makeMove(row, col) {
    if (currentState && currentState.game_over) {
        return;
    }
    
    try {
        const response = await fetch('/api/move', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                game_id: gameId,
                row: row,
                col: col
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            updateUI(data.state);
        }
    } catch (error) {
        console.error('Error making move:', error);
    }
}

// Reset game
async function resetGame() {
    try {
        const response = await fetch('/api/reset', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ game_id: gameId })
        });
        
        const data = await response.json();
        updateUI(data);
        
        // Clear all cells
        cells.forEach(cell => {
            cell.textContent = '';
            cell.classList.remove('taken', 'x', 'o');
        });
        
        statusDiv.classList.remove('winner', 'draw');
    } catch (error) {
        console.error('Error resetting game:', error);
    }
}

// Update UI based on game state
function updateUI(state) {
    currentState = state;
    
    // Update board
    state.board.forEach((row, rowIndex) => {
        row.forEach((cell, colIndex) => {
            const cellElement = document.querySelector(
                `.cell[data-row="${rowIndex}"][data-col="${colIndex}"]`
            );
            
            if (cell !== '') {
                cellElement.textContent = cell;
                cellElement.classList.add('taken', cell.toLowerCase());
            }
        });
    });
    
    // Update status
    if (state.game_over) {
        if (state.winner) {
            statusDiv.textContent = `Player ${state.winner} Wins! 🎉`;
            statusDiv.classList.add('winner');
            statusDiv.classList.remove('draw');
        } else {
            statusDiv.textContent = "It's a Draw! 🤝";
            statusDiv.classList.add('draw');
            statusDiv.classList.remove('winner');
        }
    } else {
        statusDiv.textContent = `Current Player: ${state.current_player}`;
        statusDiv.classList.remove('winner', 'draw');
    }
}

// Event listeners
cells.forEach(cell => {
    cell.addEventListener('click', () => {
        const row = parseInt(cell.getAttribute('data-row'));
        const col = parseInt(cell.getAttribute('data-col'));
        
        if (!cell.classList.contains('taken')) {
            makeMove(row, col);
        }
    });
});

resetBtn.addEventListener('click', resetGame);

// Start the game when page loads
initGame();
