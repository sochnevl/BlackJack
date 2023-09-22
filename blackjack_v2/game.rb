# frozen_string_literal: true

require_relative 'card'
require_relative 'deck'
require_relative 'player'
require_relative 'user'
require_relative 'dealer'

class Game
  attr_accessor :game_over
  attr_reader :deck

  ROUND_BET = 20
  ROUND_BET_PLAYER = 10
  MAX_CARDS = 3

  def initialize
    @deck = Deck.new
    @deck.generate
    @dealer = Dealer.new('Dealer')
    @bank = 0
    @game_over = false
  end

  def start
    greeting
    loop do
      reset_state
      give_cards
      game_bet
      show_state
      round until @game_over
      finish_game

      if @player.no_money? || @dealer.no_money?
        puts 'У одного  из игроков закончились деньги, игра окончена'
        break
      end

      puts "Хотите сыграть еще? (Введите 'да' или 'нет')."
      continue = gets.chomp.downcase
      break unless continue == 'да'
    end
  end

  def show_state
    puts "Ваши карты: #{@player.show_cards}, у вас очков: #{@player.points}"
    puts 'Карты дилера: ***'
  end

  def reveal_cards
    puts 'Вскрываем карты!'
    puts "Ваши карты: #{@player.show_cards}, у вас очков: #{@player.points}"
    puts "Карты дилера: #{@dealer.show_cards}, у дилера очков: #{@dealer.points}"
    winner = define_winner
    finish_round(winner)
    @game_over = true
  end

  def define_winner
    if @player.points > Player::BLACKJACK_LIMIT && @dealer.points > Player::BLACKJACK_LIMIT
      nil
    elsif @player.points <= Player::BLACKJACK_LIMIT && (@dealer.points > Player::BLACKJACK_LIMIT || @player.points > @dealer.points)
      @player
    elsif @dealer.points <= Player::BLACKJACK_LIMIT && (@player.points > Player::BLACKJACK_LIMIT || @dealer.points > @player.points)
      @dealer
    end
  end

  private

  def round
    if @player.cards.length == MAX_CARDS && @dealer.cards.length == MAX_CARDS
      reveal_cards
    else
      @player.move(self)
      @dealer.move(self)
    end
  end

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

    @bank += ROUND_BET
  end

  def reset_state
    @player.cards = []
    @dealer.cards = []
    @game_over = false
  end

  def finish_round(winner)
    if winner.is_a?(Player)
      winner.balance += @bank
      puts "Победил #{winner.name}, его баланс увеличен! У игрока #{winner.balance}$"
      @bank = 0
    else
      puts 'Ничья! Деньги Возвращаются игрокам.'
      @player.balance += ROUND_BET_PLAYER
      @dealer.balance += ROUND_BET_PLAYER
      @bank = 0
      puts "Баланс игрока: #{@player.balance}$, баланс дилера: #{@dealer.balance}$"
    end
    @game_over = true
  end

  def greeting
    puts 'Это игра BlackJack! Введите свое имя и начнем!'
    name = gets.chomp
    @player = User.new(name)
  end

  def finish_game
    return if @game_over

    winner = define_winner
    finish_round(winner)
  end
end

game = Game.new
game.start
