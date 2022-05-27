
class Game
    attr_accessor :code_length, :number_of_turns
    @@feedback; @@guesses; @@player_side; @@code; @@game_over
    public
    def play
        turn = 1

        determine_side
        code_breaker = CodeBreaker.new(code_length)
        code_maker = CodeMaker.new(code_length)
        if @@player_side == 2
            code_maker.enter_code
            @@code = code_maker.code
        end

        puts "welcome to codebreaker! try to guess the 4 digit number. Enter 'info' to check the rules."
        print_board
        while @@game_over == false and turn <= 8
            if @@player_side == 1
                code_breaker.make_guess
                code_maker.compare_guess_to_code
                print_board
            else
                code_breaker.generate_guess
                puts "The computer guesses: #{@@guesses.last}"
                code_maker.compare_guess_to_code
                sleep(1.3)
                print_board
            end
            turn += 1
        end
        print_board
        if @@guesses.last == @@code
            puts "The Codebreaker wins! The code was #{code_maker.code}"
        else
            puts "The Codebreaker loses! The code was #{code_maker.code}"
        end
    end
    private

    def determine_side
        puts ("Enter 1 for Codebreaker and 2 for Codemaker")
        side = gets.chomp
        if side.to_i.to_s == side and side.to_i.between?(1,2)
            @@player_side = side.to_i
            if side == '1'
                puts "You have chosen Codebreaker!"
            else
                puts "You have chosen Codemaker!"
            end
        else
            determine_side
        end
    end

    def print_board()
        game_board = []
        number_of_guesses = @@guesses.length
        space = ' ' * 45

        empty_row =   space + '( ) ( ) ( ) ( )         o o o o'
        lines =      space + '---------------'
        empty_rows = number_of_turns - number_of_guesses

        empty_rows.times do
            game_board << lines
            game_board << empty_row
        end

        @@guesses.reverse.zip(@@feedback.reverse).each do |guess, fb|

            str = "(#{guess[0]}) (#{guess[1]}) (#{guess[2]}) (#{guess[3]})         "
            str += "#{fb[0]} #{fb[1]} #{fb[2]} #{fb[3]}" + '         '
            game_board << lines
            game_board << space + str
        end

        game_board << space
       puts game_board
    end

    def initialize(code_length = 4, number_of_turns = 8)
        self.code_length = code_length
        @@game_over = false
        self.number_of_turns = number_of_turns
        @@feedback = []
        @@guesses = []
    end

    def victory
        puts "You win!"
        exit
    end

end

class CodeBreaker < Game
    attr_accessor :already_guessed
    public
    def make_guess
            puts "Enter your guess"
            guess = gets.chomp
            validate_guess(guess)
    end

    def generate_guess
        guess = []

        if @@guesses.empty?
            4.times {guess << random}
        else
            (0..3).each do |i|
                if @@guesses.last[i] == @@code[i]
                    guess[i] = @@code[i]
                    @already_guessed << guess[i]
                else
                    guess[i] = random
                    while @already_guessed.include?(guess[i])
                        guess[i] = random
                    end
                end
            end
        end
        @@guesses << guess
    end

    def random
        (rand * 6 + 1).floor
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
                @@guesses << guess.split("").map {|i| i.to_i}
            else 
                print_error_msg
            end
        else 
            print_error_msg
        end
    end

    def initialize(code_length)
        self.code_length = code_length
        self.already_guessed = []
    end
    private
    def print_error_msg
        puts 'Invalid input.'
        make_guess
    end
end

class CodeMaker < Game
    attr_accessor :code, :code_length
    public
    
    def compare_guess_to_code()
        matches = []
        last_guess = @@guesses.last


        if @@guesses.last == @code
            @@game_over = true
        end

        temp_string = ''
        (0..code_length - 1).each do |i|
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
        @@feedback << temp_string.split("")
    end

    def initialize(code_length)
        @code = []
        @code_length = code_length
        
        while @code.length < code_length
            @code << (rand * 6 + 1).floor
            @code.uniq!
        end
    end

    def enter_code
        error_msg = 'Invalid.'
        puts "Enter code with 4 unique digits."
        code = gets.chomp
        if code.to_i.to_s == code
            code = code.split("")
            all_valid = code.to_a.all? { |digit| digit.to_i.between?(1,6) }
            if all_valid
                code = code.map {|digit| digit.to_i}
                if code.uniq == code
                    @@code = code
                else
                    puts "All digits must be unique, i.e., not duplicated."
                    enter_code
                end
            else
                puts error_msg
                enter_code
            end
        else
            puts error_msg
            enter_code
        end
    end

end

game = Game.new
game.play