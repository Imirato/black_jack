# frozen_string_literal: true

class Player
  attr_reader :cards, :money, :name

  def initialize(name)
    @cards = []
    @money = 100
    @name = name
  end

  def add_card(card)
    @cards << card
  end

  def add_cards(cards)
    @cards += cards
  end

  def place_bet(sum)
    raise 'Ставка не может быть отрицательным числом!' if sum.negative?
    raise 'Размер ставки не может быть больше количества денег игрока!' if sum > @money

    @money -= sum
  end

  def get_money(sum)
    raise 'Выигрыш не может быть отрицательным числом!' if sum.negative?

    @money += sum
  end

  def delete_cards
    @cards.clear
  end
end
