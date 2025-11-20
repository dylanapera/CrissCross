"""
Tic-Tac-Toe (Knots and Crosses) Game Logic
"""

class TicTacToe:
    def __init__(self):
        """Initialize a new game board."""
        self.board = [['' for _ in range(3)] for _ in range(3)]
        self.current_player = 'X'
        self.winner = None
        self.game_over = False
        
    def make_move(self, row, col):
        """
        Make a move on the board.
        
        Args:
            row (int): Row index (0-2)
            col (int): Column index (0-2)
            
        Returns:
            bool: True if move was successful, False otherwise
        """
        if self.game_over:
            return False
            
        if row < 0 or row > 2 or col < 0 or col > 2:
            return False
            
        if self.board[row][col] != '':
            return False
            
        self.board[row][col] = self.current_player
        
        # Check for winner or draw
        if self.check_winner():
            self.winner = self.current_player
            self.game_over = True
        elif self.is_board_full():
            self.game_over = True
        else:
            # Switch player
            self.current_player = 'O' if self.current_player == 'X' else 'X'
            
        return True
    
    def check_winner(self):
        """
        Check if current player has won.
        
        Returns:
            bool: True if current player won, False otherwise
        """
        player = self.current_player
        
        # Check rows
        for row in range(3):
            if all(self.board[row][col] == player for col in range(3)):
                return True
        
        # Check columns
        for col in range(3):
            if all(self.board[row][col] == player for row in range(3)):
                return True
        
        # Check diagonals
        if all(self.board[i][i] == player for i in range(3)):
            return True
            
        if all(self.board[i][2-i] == player for i in range(3)):
            return True
            
        return False
    
    def is_board_full(self):
        """
        Check if the board is full (draw condition).
        
        Returns:
            bool: True if board is full, False otherwise
        """
        return all(self.board[row][col] != '' for row in range(3) for col in range(3))
    
    def reset_game(self):
        """Reset the game to initial state."""
        self.board = [['' for _ in range(3)] for _ in range(3)]
        self.current_player = 'X'
        self.winner = None
        self.game_over = False
    
    def get_board_state(self):
        """
        Get the current state of the game.
        
        Returns:
            dict: Dictionary containing game state information
        """
        return {
            'board': self.board,
            'current_player': self.current_player,
            'winner': self.winner,
            'game_over': self.game_over
        }
