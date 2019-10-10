require 'pry'

class TicTacToe
  class Game
    def self.play(ai = false)
      new(ai).play
    end

    def initialize(ai)
      @ai = ai
      pretty_print_board
    end

    def play
      @current_player = players.next
      puts "#{@current_player} it's your turn! Pick your space using the grid system, letter first (e.g. A1, A2, etc.)."
      computer_turn? ? make_move(*ai_move) : make_move(*get_human_move)
      pretty_print_board
      if winning_move?
        puts "#{@current_player} wins!"
      elsif cat
        puts "It's a cat!"
      else
        play
      end
    end

    private

    def computer_turn?
      @current_player == "O" && ai?
    end

    def ai?
      @ai
    end

    def players
      @players ||= ["X", "O"].cycle
    end

    def board
      @board ||=
        [
          [" ", " ", " "],
          [" ", " ", " "],
          [" ", " ", " "]
      ]
    end

    def pretty_print_board
      puts "
        A   B   C
      +---+---+---+
    1 | #{board[0][0]} | #{board[0][1]} | #{board[0][2]} |
      +---+---+---+
    2 | #{board[1][0]} | #{board[1][1]} | #{board[1][2]} |
      +---+---+---+
    3 | #{board[2][0]} | #{board[2][1]} | #{board[2][2]} |
      +---+---+---+

      "
    end

    def get_human_move
      input = gets.chomp
      move = HumanMove.new(board, *indexify_move(input))
      until move.valid?
        puts "#{input} is not a valid move, please try again! The space must be empty"
        input = gets.chomp
        move = HumanMove.new(board, *indexify_move(input))
      end
      return move.row, move.column
    end

    def ai_move
      move = AiMove.new(board)
      return move.row, move.column
    end

    def make_move(row, column)
      board[row][column] = @current_player
    end

    def indexify_move(move)
      move.downcase!
      row = move[1].to_i - 1
      column = column_letter_to_array_index[move[0]]
      return row, column
    end

    def column_letter_to_array_index
      { "a" =>  0,
        "b" =>  1,
        "c" =>  2
      }
    end

    def winning_move?
      winning_rows? ||
        winning_columns? ||
        winning_diagonals?
    end

    def winning_rows?
      board.any? do |row|
        row.all? { |spot| spot == @current_player }
      end
    end

    def winning_columns?
      board.transpose.any? do |column|
        column.all? { |spot| spot == @current_player }
      end
    end

    def winning_diagonals?
      [board[0][0], board[1][1], board[2][2]].all? { |spot| spot == @current_player } ||
        [board[0][2], board[1][1], board[2][0]].all? { |spot| spot == @current_player }
    end

    def cat
      board.flatten.map(&:strip).none?(&:empty?)
    end
  end
end

class TicTacToe
  class Move
    attr_accessor :row, :column
    attr_reader :board
  end
end

class TicTacToe
  class AiMove < Move

    def initialize(board)
      @board = board
      find_best_move
    end

    private

    def find_best_move
      pick_first_empty_spot unless possible_winning_move("O") || possible_winning_move("X")
    end

    def possible_winning_move(player)
      row = winning_row(player)
      column = winning_column(player)
      diagonal = winning_diagonal(player)

      if row
        column = board[row].find_index {|spot| spot.strip.empty? }
        set_winning_move(row, column)
      elsif column
        row = board.transpose[column].find_index {|spot| spot.strip.empty? }
        set_winning_move(row, column)
      else
        diagonal
      end
    end

    def winning_column(player)
      column = board.transpose.find_index do |column|
        column.sort.join.include?(" #{player}#{player}")
      end
      column
    end

    def winning_row(player)
      row = board.find_index do |row|
        row.sort.join.include?(" #{player}#{player}")
      end
      row
    end

    def winning_diagonal(player)
      if down_diagonal.sort.join.include?(" #{player}#{player}")
        row = down_diagonal.find_index do |spot|
          spot == " "
        end
        set_winning_move(row, row)
      elsif up_diagonal.sort.join.include?(" #{player}#{player}")
        row = up_diagonal.find_index do |spot|
          spot == " "
        end
        set_winning_move(row, up_diagonal_column[row])
      else
        false
      end
    end

    def down_diagonal
      [board[0][0], board[1][1], board[2][2]]
    end

    def up_diagonal
      [board[0][2], board[1][1], board[2][0]]
    end

    def up_diagonal_column
      [2, 1, 0]
    end

    def set_winning_move(row, column)
      self.row = row
      self.column = column
      true
    end

    def pick_first_empty_spot
      self.row = board.find_index {|row| row.any? {
        |spot| spot.strip.empty? }
      }
      if self.row
        self.column = board[self.row].find_index {|spot| spot.strip.empty? }
      end
    end
  end
end

class TicTacToe
  class HumanMove < Move

    def initialize(board, row, column)
      @board = board
      @row = row
      @column = column
    end

    def valid?
      (0..2).include?(row) &&
        (0..2).include?(column) &&
        board[row][column].strip.empty?
    end
  end
end

# TicTacToe::Game.play(true)

describe TicTacToe::AiMove do
  subject(:ai_move) { described_class.new(board) }

  context "when given the opportunity for a winning row move" do
    # winning row
    let(:board) { [["X", " ", " "], ["X", " ", " "],["O", "O", " "]] }
    it "picks it" do
      expect([ai_move.row, ai_move.column]).to eq([2, 2])
    end
  end

  context "when given the opportunity for a winning column move" do
    let(:board) { [["O", " ", "X"], ["O", " ", " "],[" ", "X", " "]] }
    it "picks it" do
      expect([ai_move.row, ai_move.column]).to eq([2, 0])
    end
  end

  context "when given the opportunity for a winning diagonal move" do
    # winning diagonal
    let(:board) { [["O", " ", "X"],["X", "O", " "],[" ", " ", " "]] }
    it "picks it" do
      expect([ai_move.row, ai_move.column]).to eq([2, 2])
    end
  end

  context "when given the opportunity to block a winning move" do
    # winning diagonal
    let(:board) { [["X", " ", "O"],[" ", "X", " "],[" ", " ", " "]] }
    it "picks it" do
      expect([ai_move.row, ai_move.column]).to eq([2, 2])
    end
  end

  context "when given the opportunity to block or win" do
    # winning row
    let(:board) { [["X", " ", "X"], [" ", "X", " "],["O", " ", "O"]] }

    it "prioritizes winning" do
      expect([ai_move.row, ai_move.column]).to eq([2, 1])
    end
  end
end
