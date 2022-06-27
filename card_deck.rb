# frozen_string_literal: true

require_relative 'card'

class CardDeck
  CARD_VALUES = %w[2 3 4 5 6 7 8 9 10 В Д К Т].freeze
  CARD_SUITS = %w[+ <> ^ <3].freeze
  CARD_SCORES = { '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8,
                  '9': 9, '10': 10, 'В': 10, 'Д': 10, 'К': 10, 'Т': 11 }.freeze

  def initialize
    @cards = []

    CARD_SUITS.each do |suit|
      CARD_VALUES.each { |value| @cards << Card.new(value, suit) }
    end

    @cards.shuffle!
  end

  def deal_cards(quantity)
    quantity.times.map { deal_card }
  end

  def deal_card
    @cards.pop
  end

  def card_value(card)
    CARD_SCORES[card.value.to_sym]
  end
end
