# Rule
# Player needs to guess the secret code that are 4 digits long.
# Each digit is a color which there are 8 choices to choose from.
# There is no duplicate color in the secret code.
# After every guess, the game tells player number of hits and misses.
# Hits can be either home-run where the placement and the color is correct or
# hit where the color is correct but the placement is wrong.
# Player needs to corretly guess the secret code within 12 turns.

# starts the game
# manages overall game flow
# checks for win
class MasterMind
  def initialize
    @color_options = ['red', 'blue', 'green', 'yellow', 'orange', 'white', 'pink', 'violet']
    @max_turns = 12
    @secret_length = 4
    @secret_code = @color_options.sample(@secret_length)
    puts "Play Mastermind!\n\n"
    @game_board = GameBoard.new
    @player = Player.new

    @mode = binary_response('create', 'guess')
    if @mode == 'guess'
      play_game(@max_turns, @secret_length)
    elsif @mode == 'create'
      computer_plays(@max_turns, @secret_length)
    end
  end

  def play_game(max_turns, secret_length)
    p @secret_code
    turn = 0
    win = nil
    hints = []
    while turn < max_turns and win == nil
      puts "\nYou have #{max_turns - turn} turns to guess the secret code.\n"
      puts "\nPlease choose #{secret_length} from #{@color_options.join(", ")}.\n\n"
      guess = @player.make_guess(@color_options, secret_length)
      @game_board.add_guess(guess)
      hints << get_hint(guess)
      if hints[-1][0] == secret_length
        win = true
      end
      @game_board.show_curr_state(hints)

      turn += 1
    end
    puts
    if win == true
      puts "Congratulations, you got it!\n"
    else
      puts "Sorry, you ran out of guesses\n\n"
    end

    play_again(max_turns, secret_length)
  end

  def computer_plays(max_turns, secret_length)
    @secret_code = choose_secret_code(secret_length)
    p @secret_code
  end

  def choose_secret_code(secret_length)
    valid_inputs = nil
    inputs = nil

    until valid_inputs && valid_inputs.length == secret_length &&
          valid_inputs.uniq.length == valid_inputs.length &&
          valid_inputs.all? { |input| @color_options.any? (input) }

      print "\nEnter your secret code that is #{secret_length} different colors. (Separated by space): "
      inputs = gets.chomp.downcase.split

      # need to check for if there are secret_length inputs
      if inputs.length != secret_length
        puts "\nInvalid input. Please ensure you input exactly #{secret_length} colors.\n"
      # checks if all inputs are unique
      elsif inputs.map { |input| input[0] }.uniq.length != inputs.length
        puts "\nInvalid input. Please ensure all colors are unique.\n"
      # checks if all inputs are valid color
      elsif !inputs.all? { |input| @color_options.any? { |option| option.start_with?(input) } }
        puts "\nInvalid input. Please ensure all colors are part of #{@color_options}.\n"
      end

      # if input is a valid substring
      if inputs.all? { |input| @color_options.any? { |option| option.start_with?(input) } }
        # turn substring into full color
        valid_inputs = inputs.map do |input|
          @color_options.find { |color| color.start_with?(input) }
        end
      end

    end

    valid_inputs
  end

  # evaluates guess and returns hint
  def get_hint(guesses)
    hit = 0
    ball = 0

    guesses.each_with_index do |guess, index|
      if guess == @secret_code[index]
        hit += 1
      else
        if @secret_code.include?(guess)
          ball += 1
        end
      end
    end
    return [hit, ball]
  end

  def play_again(max_turns, secret_length)
    mt = max_turns
    sl = secret_length
    puts "\nPlay Again?\n\n"
    if binary_response('yes', 'no') == "yes"
      puts "\nPlay with same settings?\n"
      if binary_response('yes', 'no') == 'no'
        puts "\nChoose Max Turns (Max 20): "
        mt = gets.to_i
        puts "\nChoose Secret Length (Max 8): "
        sl = gets.to_i
      end
      reset
      puts "\nNew Game!\n"
      play_game(mt, sl)
    else
      puts "\nThank you for playing. Have a good day!"
    end
  end

  def reset
    @secret_code = @color_options.sample(@secret_length)
    @game_board = GameBoard.new
  end

  # takes two strings and asks until a substring of either one is inputted
  def binary_response(op1, op2)
    response = nil
    options = [op1, op2]
    puts "Do you want to #{op1} or #{op2} the secret code?\n"
    until response && options.any? { |opt| opt.start_with?(response) }
      print "\nPlease enter '#{op1.capitalize}' or '#{op2.capitalize}': \n"
      response = gets.chomp.downcase
    end
    return options.find { |opt| opt.start_with?(response) }
  end
end

# displays board up to current state
class GameBoard
  def initialize()
    @game_board = Array.new
  end

  def show_curr_state(hints)
    @game_board.each_with_index do |guess, index|
      puts "\nGuess ##{index + 1}: #{guess.join(' ')} " + "|| " + "Hits: #{hints[index][0]} Balls: #{hints[index][1]} "
    end
  end

  def add_guess(guess)
    @game_board << guess
  end
end

# makes a guess
class Player
  def make_guess(options, secret_length)
    Array.new(secret_length) { check_option_validity(options) }
  end

  def check_option_validity(options)
    input = ''
    # accept any substring of options
    loop do
      input = gets.chomp.downcase
      if options.include?(input) ||
         options.any? { |color| color.downcase.start_with?(input) }
        # return the original option
        input = options.find { |color| color.start_with?(input) }
        return input
      else
        puts "\nInvalid input. Please choose from #{options.join(", ")}.\n\n"
      end
    end
  end
end

game = MasterMind.new
