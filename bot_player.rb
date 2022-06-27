# frozen_string_literal: true

class BotPlayer < Player
  SKIP_POINTS = 17

  def initialize(name = 'Дилер')
    super
  end

  def auto_turn(card_deck, score)
    return :skip if score >= SKIP_POINTS

    add_card(card_deck.deal_card)

    :take_card
  end
end
