# frozen_string_literal: true

class Dealer < Player
  POINTS_WHEN_DEALER_MISS = 17
  BLACKJACK_LIMIT = 21

  def move(game)
    return if game.game_over

    puts 'Ход дилера: .....'
    if @points < POINTS_WHEN_DEALER_MISS && @cards.size < MAX_CARDS
      puts 'Дилер решил добавить себе карту'
      make_move(game.deck)
      game.show_state
    else
      puts 'Дилер пропускает ход'
      nil
    end
  end
end
