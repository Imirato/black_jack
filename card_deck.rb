# frozen_string_literal: true

class CardDeck
  CARDS = %w[
    2+ 3+ 4+ 5+ 6+ 7+ 8+ 9+ 10+ В+ Д+ К+ Т+
    2^ 3^ 4^ 5^ 6^ 7^ 8^ 9^ 10^ В^ Д^ К^ Т^
    2<3 3<3 4<3 5<3 6<3 7<3 8<3 9<3 10<3 В<3 Д<3 К<3 Т<3
    2<> 3<> 4<> 5<> 6<> 7<> 8<> 9<> 10<> В<> Д<> К<> Т<>
  ]

  def initialize
    @cards_array = CARDS.clone
  end

  def deal_cards(quantity)
    quantity.times.map { deal_card }
  end

  def deal_card
    @cards_array.delete_at(rand(@cards_array.length))
  end

  def refresh
    @cards_array = CARDS.clone
  end
end
