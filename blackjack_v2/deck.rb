# frozen_string_literal: true

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
        @cards << Card.new(suit, value)
      end
    end
    @cards.shuffle!
  end

  def take_card
    generate if @cards.empty?
    @cards.pop
  end
end
