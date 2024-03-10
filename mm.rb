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
#checks for win
class MasterMind
   def initialize()
      @color_options=['red','blue','green','yellow','orange','white','pink','violet']
      @max_turns=12
      @secret_code=@color_options.sample(4)

      puts "Play Mastermind!\n\n"
      @game_board=GameBoard.new
      @player=Player.new

      play_game
   end

   def play_game
      turn=0
      win=nil
      while turn<12 and win==nil
         puts "\nPlease choose 4 from #{@color_options.join(", ")}.\n\n"
         guess= @player.make_guess(@color_options)
         @game_board.add_guess(guess)
         @game_board.show_curr_state

         turn+=1
      end
      puts
      if win==true
         puts "Congratulations, you got it!"
      else
         puts "Sorry, you ran out of guesses"
      end
   end

end

#displays board up to current state
class GameBoard
   def initialize()
      @game_board=Array.new
   end

   def show_curr_state
      @game_board.each_with_index do |guess,index|
         puts "\nGuess ##{index+1}: #{guess.join(' ')}"
      end
   end

   def add_guess(guess)
      @game_board << guess
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
   def make_guess(options)
      Array.new(4) { check_validity(options) }
   end

   def check_validity(options)
      input=''
      #accept any substring of options
      loop do
         input=gets.chomp.downcase
         if options.include?(input) ||
            options.any? {|color| color.downcase.start_with?(input)}

            #return the original option
            input= options.select {|color| color.start_with?(input)}
            return input
         else 
            puts "\nInvalid input. Please choose from #{options.join(", ")}.\n\n"
         end
      end
      
      
   end

end

game=MasterMind.new