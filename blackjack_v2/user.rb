# frozen_string_literal: true

class User < Player
  def move(game)
    return if game.game_over

    action
    player_choice = gets.chomp.to_i

    case player_choice
    when 1
      if @cards.size < MAX_CARDS
        make_move(game.deck)
        game.show_state
      else
        puts 'Вы уже имеете максимальное количсетво карт - 3 шт.'
        nil
      end
    when 3
      game.reveal_cards
    end
  end

  def action
    puts 'Ход игрока: '
    puts 'Выберите действие: 1. Сделать ход; 2. Пропустить ход (ход переходит дилеру); 3. Открыть карты (итоги игры)'
  end
end
