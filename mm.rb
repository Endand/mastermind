#Rule
#Player needs to guess the secret code that are 4 digits long. 
#Each digit is a color which there are 8 choices to choose from.
#There is no duplicate color in the secret code.
#After every guess, the game tells player number of hits and misses.
#Hits can be either home-run where the placement and the color is correct or
#hit where the color is correct but the placement is wrong.
#Player needs to corretly guess the secret code within 12 turns.


#starts the game
#manages overall game flow
#check for win
class MasterMind
   def initialize()
      @color_options=['red','blue','green','yellow','orange','white','pink','violet']
      @max_turns=12

      puts "Play Mastermind!\n\n"

      @game_board=GameBoard.new
      @player=Player.new

      play_game
   end

   def play_game
      @player.make_guess
   end

end

#displays board up to current state
class GameBoard
   def initialize()
      @game_board=Array.new
   end
end

#checks for input and returns hint
class Analyzer
   def initialize(secret,guess)
      @secret=secret
      @guess=guess
   end
end

#makes a guess
class Player
   def make_guess()
      puts 'guess'
   end
end

game=MasterMind.new