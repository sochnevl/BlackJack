# frozen_string_literal: true

class Card
  attr_reader :suit, :value

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def points
    case @value
    when 'J', 'Q', 'K' then 10
    when 'A' then 11 # По умолчанию, но могут быть исключения
    else value.to_i
    end
  end
end
