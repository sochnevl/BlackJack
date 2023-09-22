# frozen_string_literal: true

class Player
  attr_accessor :cards, :points, :balance
  attr_reader :name

  BET = 10
  BLACKJACK_LIMIT = 21
  MAX_CARDS = 3
  BALANCE = 100

  def initialize(name)
    @name = name
    @balance = BALANCE
    @cards = []
    @points = 0
  end

  def make_move(deck)
    return unless @cards.length < MAX_CARDS

    @cards << deck.take_card
    calculate_points
  end

  def make_bet
    @balance -= BET
  end

  def calculate_points
    @points = 0
    aces = 0

    @cards.each do |card|
      @points += card.points
      aces += 1 if card.value == 'A'
    end

    while @points > BLACKJACK_LIMIT && aces.positive?
      @points -= 10
      aces -= 1
    end
  end

  def show_cards
    @cards.map { |card| "#{card.value} #{card.suit}" }.join(' ')
  end

  def no_money?
    @balance <= 0
  end
end
