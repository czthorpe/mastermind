
class Game
    attr_accessor :code_length, :game_over, :number_of_turns, :all_feedback, :player_side
    public
    def play
        code_breaker = CodeBreaker.new(code_length)
        code_maker = CodeMaker.new(code_length)
        turn = 1

        puts "welcome to codebreaker! try to guess the 4 digit number. Enter 'info' to check the rules."
        puts "do you want to be the codebreaker or the codemaker? enter 1 or 2."
        print_board(number_of_turns)

        while !@game_over and turn <= 8
            guess = code_breaker.make_guess(@player_side)
            code_maker.compare_guess_to_code(code_breaker.guesses, self)
            print_board(code_maker.feedback, code_breaker.guesses, @number_of_turns)
            turn += 1
        end
        puts "You lose. The code was #{code_maker.code}"
    end
    private
    def print_board(all_feedback = [], guesses = [], number_of_turns)
        game_board = []
        number_of_guesses = guesses.length
        space = ' ' * 45

        empty_row =   space + '( ) ( ) ( ) ( )         o o o o'
        lines =      space + '---------------'
        empty_rows = number_of_turns - number_of_guesses

        empty_rows.times do
            game_board << lines
            game_board << empty_row
        end

        guesses.reverse.zip(all_feedback.reverse).each do |guess, feedback|

            str = "(#{guess[0]}) (#{guess[1]}) (#{guess[2]}) (#{guess[3]})         "
            str += "#{feedback[0]} #{feedback[1]} #{feedback[2]} #{feedback[3]}" + '         '
            game_board << lines
            game_board << space + str
        end
       puts game_board
    end

    def choose_side
        choice = gets.chomp

        if choice.to_i.to_s = choice and choice.to_i >= 1 and choice.to_i <= 2
            if choice == 1
                @player_side = 'codebreaker'
            else
                @player_side = 'codemaker'
            end
        else 
            choose_side
        end

    end

    def initialize(code_length = 4, number_of_turns = 8)
        self.code_length = code_length
        self.game_over = false
        self.number_of_turns = number_of_turns
        self.all_feedback = []
    end

    def self.victory
        puts "You win!"
        exit
    end

end

class CodeBreaker
    attr_accessor :guesses, :code_length, :possible_matches, :matches
    public
    def make_guess(player_side)
        if player_side = 'codebreaker'
            puts "Enter your guess"
            guess = gets.chomp
            validate_guess(guess)
        else
            generate_guess
        end
    end

    def validate_guess(guess)
        if guess.downcase == 'info'
            puts "\t\tThe goal is to guess the #{@code_length} digit code. 
            If one of the numbers in your guess matches both the position and the value of the number
            in the code, an r (red) will show up in the bank on the right.
            If one of the numbers in your guesses matches only the value of one of the numbers in the code,
            a w (white) will appear. o stands for no match.
            Your guess must take the form of a 4 digit number, ex: 1144"
            make_guess
        end
        if guess.length == 4 and guess.to_i.to_s == guess #checks if it's an int
            nums_in_valid_range = (0..(code_length-1)).all? do |i| 
                guess[i].to_i <= 6 and guess[i].to_i > 0
            end
            if nums_in_valid_range
                guesses << guess.split("").map {|i| i.to_i}
            else 
                print_error_msg
            end
        else 
            print_error_msg
        end
    end

    def generate_guess
        codemaker = CodeMaker.new()
        code = codemaker.code

        
    end

    def initialize(code_length)
        self.guesses = []
        self.code_length = code_length
    end
    private
    def print_error_msg
        puts 'Invalid input.'
        make_guess
    end
end

class CodeMaker
    attr_accessor :code, :code_length, :feedback
    public
    
    def compare_guess_to_code(guess, game)
        matches = []
        last_guess = guess.last


        if guess.last == @code
            game.game_over = true
            Game.victory
        end

        temp_string = ''
        (0..code_length-1).each do |i|
            if @code[i] == last_guess[i]
                matches << code[i]
                temp_string += 'r'
            end
        end
        last_guess.uniq.each do |i|
            if @code.include?(i) and temp_string.length <= 4 and !matches.include?(i)
                temp_string += 'w'
            end
        end
        temp_string += ('o' * (4 - temp_string.length))
        @feedback << temp_string.split("")
    end

    def initialize(code_length)
        @code = []
        @feedback = []
        @code_length = code_length
        
        while @code.length < code_length
            @code << (rand * 6 + 1).floor
            @code.uniq!
        end
    end

end

game = Game.new
game.play