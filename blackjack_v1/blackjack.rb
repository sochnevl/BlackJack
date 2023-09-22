# frozen_string_literal: true

class Card
  attr_reader :suit, :value, :points

  def initialize(suit, value, points)
    @suit = suit
    @value = value
    @points = points
  end
end

class Deck
  attr_reader :cards

  def initialize
    @cards = []
  end

  def generate
    suits = ['♠', '♣', '♥', '♦']
    values = %w[2 3 4 5 6 7 8 9 10 J Q K A]

    suits.each do |suit|
      values.each do |value|
        # Определите количество очков в зависимости от номинала
        points = case value
                 when 'J', 'Q', 'K' then 10
                 when 'A' then 11 # По умолчанию, но могут быть исключения
                 else value.to_i
                 end

        @cards << Card.new(suit, value, points)
      end
    end
    @cards.shuffle!
  end

  def take_card
    @cards.pop
  end
end

class Player
  attr_accessor :cards, :player_points, :balance
  attr_reader :name

  def initialize(name)
    @name = name
    @balance = 100
    @cards = []
    @player_points = 0
  end

  def make_move(deck)
    return unless @cards.length < 3

    @cards << deck.take_card
    calculate_points
  end

  def make_bet
    @balance -= 10
  end

  def calculate_points
    @player_points = 0
    aces = 0

    @cards.each do |card|
      @player_points += card.points
      aces += 1 if card.value == 'A'
    end

    while @player_points > 21 && aces.positive?
      @player_points -= 10
      aces -= 1
    end
  end

  def show_cards
    @cards.map { |card| "#{card.value} #{card.suit}" }.join(' ')
  end
end

class User < Player
end

class Dealer < Player
end

class Game
  def initialize
    @deck = Deck.new
    @deck.generate
    @dealer = Dealer.new('Dealer')
    @bank = 0
    @game_over = false
  end

  def start
    puts 'Это игра BlackJack! Введите свое имя и начнем!'
    name = gets.chomp
    @player = User.new(name)
    loop do
      reset_state
      give_cards
      game_bet
      show_state
      round until @game_over # пока игра не закончена

      unless @game_over
        winner = define_winner
        finish_round(winner)
      end

      puts "Хотите сыграть еще? (Введите 'да' или 'нет')."
      continue = gets.chomp.downcase
      break unless continue == 'да'
    end
  end

  private

  def give_cards
    2.times do
      @player.cards << @deck.take_card
      @dealer.cards << @deck.take_card
    end
    @player.calculate_points
    @dealer.calculate_points
  end

  def game_bet
    @player.make_bet
    @dealer.make_bet

    @bank += 20
  end

  def reset_state
    @player.cards = []
    @dealer.cards = []
    @game_over = false
  end

  def player_move
    return if @game_over

    puts 'Ход игрока: '
    puts 'Выберите действие: 1. Сделать ход; 2. Пропустить ход (ход переходит дилеру); 3. Открыть карты (итоги игры)}'
    player_choice = gets.chomp.to_i

    case player_choice
    when 1
      if @player.cards.size < 3
        @player.make_move(@deck)
        show_state
      else
        puts 'Вы уже имеете максимальное количсетво карт - 3 шт.'
        nil
      end
    when 2
      nil
    when 3
      puts 'Вы решили открыть карты!'
      puts "Ваши карты: #{@player.show_cards}, у вас очков: #{@player.player_points}"
      puts "Карты дилера: #{@dealer.show_cards}, у дилера очков: #{@dealer.player_points}"
      winner = define_winner
      finish_round(winner)
      @game_over = true
    end
  end

  def dealer_move
    return if @game_over

    puts 'Ход дилера: .....'
    if @dealer.player_points < 17 && @dealer.cards.size < 3
      puts 'Дилер решил добавить себе карту'
      @dealer.make_move(@deck)
      show_state
    else
      puts 'Дилер пропускает ход'
      nil
    end
  end

  def round
    if @player.cards.length == 3 && @dealer.cards.length == 3
      puts 'У игроков по 3 карты, выскрываем карты!'
      puts "Ваши карты: #{@player.show_cards}, у вас очков: #{@player.player_points}"
      puts "Карты дилера: #{@dealer.show_cards}, у дилера очков: #{@dealer.player_points}"
      winner = define_winner
      finish_round(winner)
      @game_over = true
    else
      player_move
      dealer_move
    end
  end

  def show_state
    puts "Ваши карты: #{@player.show_cards}, у вас очков: #{@player.player_points}"
    puts 'Карты дилера: ***'
  end

  def define_winner
    player_points = @player.player_points
    dealer_points = @dealer.player_points

    if player_points > 21 && dealer_points > 21
      nil
    elsif player_points <= 21 && (dealer_points > 21 || player_points > dealer_points)
      @player
    elsif dealer_points <= 21 && (player_points > 21 || dealer_points > player_points)
      @dealer
    end
  end

  def finish_round(winner)
    if winner.is_a?(Player)
      winner.balance += @bank
      puts "Победил #{winner.name}, его баланс увеличен! У игрока #{winner.balance}$"
      @bank = 0
    else
      puts 'Ничья! Деньги Возвращаются игрокам.'
      @player.balance += 10
      @dealer.balance += 10
      @bank = 0
      puts "Баланс игрока: #{@player.balance}$, баланс дилера: #{@dealer.balance}$"
    end
    @game_over = true
  end
end

game = Game.new
game.start
