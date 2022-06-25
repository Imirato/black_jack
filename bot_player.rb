# frozen_string_literal: true

class BotPlayer < Player
  def initialize(name = 'Дилер')
    super
  end

  def auto_turn(card_deck, score)
    return :skip if score >= 17

    add_card(card_deck.deal_card)

    :take_card
  end
end
