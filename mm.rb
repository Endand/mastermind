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
    @color_options = %w[red blue green yellow orange white pink violet]
    @max_turns = 20
    @secret_length = 4
    @secret_code = @color_options.sample(@secret_length)
    puts "Play Mastermind!\n\n"
    @game_board = GameBoard.new
    @player = Player.new

    puts "Do you want to create or guess the secret code?\n"
    @mode = binary_response('create', 'guess')
    if @mode == 'guess'
      play_game(@max_turns, @secret_length)
    elsif @mode == 'create'

      computer_plays(@max_turns, @color_options)
    end
  end

  def play_game(max_turns, secret_length)
    turn = 0
    win = nil
    hints = []
    while turn < max_turns and win.nil?
      puts "\nYou have #{max_turns - turn} turns to guess the secret code.\n"
      puts "\nPlease choose #{secret_length} from #{@color_options.join(', ')}.\n\n"
      guess = @player.make_guess(@color_options, secret_length)
      @game_board.add_guess(guess)
      hints << get_hint(guess)
      win = true if hints[-1][0] == secret_length
      @game_board.show_curr_state(hints)

      turn += 1
    end
    puts
    if win == true
      puts "Congratulations, you got it!\n"
    else
      puts "Sorry, you ran out of guesses\n\n"
      puts "Secret Code was: #{@secret_code}"
    end

    play_again(max_turns, secret_length, 'guess')
  end

  # can only choose 4 codes long secret
  def computer_plays(max_turns, color_options)
    @secret_code = choose_secret_code(4)
    turn = 0
    guess_result = [0, 0]
    guess_history = []
    poss = color_options.repeated_permutation(4).to_a
    colors_found = false

    until turn >= max_turns

      # Each turn, guess randomly and eliminate possible choices
      guess = poss.sample
      guess = poss.sample until guess.uniq.length == 4
      
      guess_history << guess

      # evaluate the guess
      guess_result = get_hint(guess)
      hit, ball = guess_result

      break if hit == 4

      # eliminate poss based on evaluation

      # found all 4 colors
      if hit + ball == 4
        poss = eliminate_unused_colors(poss, guess)
        poss = eliminate_duplicate(poss, guess)
        colors_found = true
      # could be all 4 colors if unique but duplicates are allowed as a guess
      elsif hit + ball == 0
        other_colors = (color_options - guess)
        poss = eliminate_unused_colors(poss, other_colors)
        poss = eliminate_duplicate(poss, other_colors)
      # found 3 colors
      elsif hit + ball == 3 || (hit + ball == 1 && guess.uniq.length == 4)
        candidates = hit + ball == 3 ? guess : color_options - guess
        choose_one = color_options - candidates

        # take out one from candidates and replace with one with choose_one
        taken_out = candidates.sample
        replacer = choose_one.sample
        replaced_guess = (candidates - [taken_out]) + [replacer]

        # still counts as taking a turn
        guess_history << replaced_guess
        poss.reject! { |option| option == replaced_guess }
        turn += 1

        # evaluate the replaced_guess and eliminate poss based on it
        hit2, ball2 = get_hint(replaced_guess)
        break if hit2 == 4

        # took out wrong, put right
        if hit2 + ball2 == 4
          # replaced guess has all the correct colors so eliminate poss with other colors
          poss = poss.select { |option| option.sort == replaced_guess.sort }
        # 2 possibilities
        elsif hit2 + ball2 == 3
          # Test again with diff option on the same spot
          other_replacer = (choose_one - [replacer]).sample
          tester_guess = replaced_guess - [replacer] + [other_replacer]
          hit3, ball3 = get_hint(tester_guess)
          # still counts as taking a turn
          guess_history << tester_guess
          poss.reject! { |option| option == tester_guess }
          turn += 1

          # took out wrong, put wrong
          if hit3 + ball3 == 3
            poss = poss.reject { |option| option.include?(taken_out) }
            poss = poss.reject { |option| option.include?(replacer) }
          # took out right, put wrong
          elsif hit3 + ball3 == 2
            poss = poss.select { |option| option.include?(taken_out) }
            poss = poss.select { |option| option.include?(replacer) }

          end
          # eithert way, other_replacer is not valid color
          poss = poss.reject { |option| option.include?(other_replacer) }

        # took out right, put wrong
        elsif hit2 + ball2 == 2
          poss = poss.select { |option| option.include?(taken_out) }
          poss = poss.reject { |option| option.include?(replacer) }
        end

      end

      # when valid colors are found
      # when 4 balls, eliminate choices with the
      # same color on the same index of choice and guess
      if colors_found == true && (ball == 4)
        guess.each_with_index do |g, index|
          poss = poss.reject { |choice| choice[index] == g }
        end
      end

      # remove current guess from pool of choices
      poss.reject! { |option| option == guess }
      break if turn >= max_turns

      turn += 1
    end

    guess_history.each_with_index do |guess, index|
      puts "\nGuess #{index + 1}: #{guess.join(' ')}\n"
    end
    puts "\nSecret Code: #{@secret_code}\n"
    if guess_result[0] == 4
      puts "\nComputer guessed your secret code.\n"
    elsif turn >= max_turns
      puts "\nYou Won! Computer failed to guess your secret code.\n"
    end
    play_again(max_turns, 4, 'create')
  end

  # keeps only the poss with some combination of 'keep' array of colors
  def eliminate_unused_colors(poss, keep)
    poss.select { |option| (option | keep).sort == keep.sort }
  end

  # get poss with duplicate color out
  def eliminate_duplicate(poss, colors)
    colors.each { |color| poss = poss.reject { |option| option.count(color) > 1 } }
    poss
  end

  def choose_secret_code(secret_length)
    valid_inputs = nil
    inputs = nil

    until valid_inputs && valid_inputs.length == secret_length &&
          valid_inputs.uniq.length == valid_inputs.length &&
          valid_inputs.all? { |input| @color_options.any?(input) }

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
      next unless inputs.all? { |input| @color_options.any? { |option| option.start_with?(input) } }

      # turn substring into full color
      valid_inputs = inputs.map do |input|
        @color_options.find { |color| color.start_with?(input) }
      end

    end

    valid_inputs
  end

  # evaluates guess and returns hint
  def get_hint(guesses)
    hit = 0
    ball = 0
    seen = []
    guesses.each_with_index do |guess, index|
      if @secret_code.include?(guess)
        ball += 1 if seen.none? { |g| g == guess }
        if guess == @secret_code[index]
          hit += 1
          ball -= 1
        end
      end
      seen << guess
    end
    [hit, ball]
  end

  def play_again(max_turns, secret_length, mode)
    mt = max_turns
    sl = secret_length
    puts "\nPlay Again?\n"
    if binary_response('yes', 'no') == 'yes'
      puts "\nPlay with same settings?\n"
      if binary_response('yes', 'no') == 'no'
        puts "\nChoose Max Turns (Max 20): "
        mt = gets.to_i
        if mode == 'guess'
          puts "\nChoose Secret Length (Max 8): "
          sl = gets.to_i
        end
      end
      reset
      puts "\nNew Game!\n"
      if mode == 'guess'
        play_game(mt, sl)
      else
        computer_plays(mt, @color_options)
      end

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
    until response && options.any? { |opt| opt.start_with?(response) }
      print "\nPlease enter '#{op1.capitalize}' or '#{op2.capitalize}': \n"
      response = gets.chomp.downcase
    end
    options.find { |opt| opt.start_with?(response) }
  end
end

# displays board up to current state
class GameBoard
  def initialize
    @game_board = []
  end

  def show_curr_state(hints)
    puts '-----------------------------------------------'
    @game_board.each_with_index do |guess, index|
      puts "\nGuess ##{index + 1}: #{guess.join(' ')} " + '|| ' + "Hits: #{hints[index][0]} Balls: #{hints[index][1]} \n\n"
    end
    puts '-----------------------------------------------'
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
        puts "\nInvalid input. Please choose from #{options.join(', ')}.\n\n"
      end
    end
  end
end

game = MasterMind.new
