# frozen_string_literal: true

require_relative 'card_deck'
require_relative 'player'
require_relative 'real_player'
require_relative 'bot_player'

class Game

  MAX_ACE = 11
  MIN_ACE = 1
  ACE_VALUE_CONDITION = 10
  MAX_POINTS = 21

  attr_reader :bet, :bank

  def start_game
    create_real_player
    create_bot_player
    create_card_deck
    @bet = 10
    @bank = 0
    start_round
  end

  private

  def menu
    command_number = 1
    while command_number != 0
      puts '1. Пропустить ход'
      puts '2. Добавить карту'
      puts '3. Открыть карты'
      puts '0. Выйти из игры'

      command_number = gets.chomp.to_i
      find_command(command_number)
    end
  end

  def find_command(command_number)
    commands[command_number].call
  rescue NoMethodError
    puts 'Неверный номер команды!'
  end

  def commands
    { 1 => method(:bot_player_turn), 2 => method(:deal_card),
      3 => method(:show_result), 0 => method(:exit) }
  end

  # Game
  def start_round
    puts "Ваша ставка - #{@bet}. Остаток на счету - #{@real_player.place_bet(@bet)}"
    @real_player.add_cards(@card_deck.deal_cards(2))
    puts "Ваши карты - #{@real_player.cards.map { |card| card.to_s }.join(' ')}"
    puts "Сумма Ваших очков - #{calculate_score(@real_player.cards)}"
    puts "Ставка Дилера - #{@bet}. Остаток на счету - #{@bot_player.place_bet(@bet)}"
    @bot_player.add_cards(@card_deck.deal_cards(2))
    puts 'Карты Дилера - **'
    puts 'Сумма очков Дилера - **'
    @bank = 20
    puts "Банк - #{@bank}"
    menu
  end

  def bot_player_turn
    case @bot_player.auto_turn(@card_deck, calculate_score(@bot_player.cards))
    when :skip
      puts 'Дилер пропускает ход'
    when :take_card
      puts 'Дилер берет карту'
      calculate_score(@bot_player.cards)
    end

    show_result
  end

  def deal_card
    @real_player.add_card(@card_deck.deal_card)
    puts "Ваши карты - #{@real_player.cards.map { |card| card.to_s }.join(' ')}"
    puts "Сумма Ваших очков - #{calculate_score(@real_player.cards)}"
    bot_player_turn
  end

  def show_result
    real_player_score = calculate_score(@real_player.cards)
    bot_player_score = calculate_score(@bot_player.cards)

    puts 'Вскрываем карты'
    puts "Карты игрока - #{@real_player.cards.map { |card| card.to_s }.join(' ')}"
    puts "Карты Дилера - #{@bot_player.cards.map { |card| card.to_s }.join(' ')}"
    puts "Счет игрока - #{real_player_score}"
    puts "Счет Дилера - #{bot_player_score}"

    if (real_player_score > bot_player_score && real_player_score <= MAX_POINTS) ||
      (real_player_score < bot_player_score && bot_player_score > MAX_POINTS)
      puts "Поздравляем, #{@real_player.name}! Вы выиграли"
      @real_player.get_money(@bank)
    elsif bot_player_score <= MAX_POINTS
      puts 'Выиграл Дилер'
      @bot_player.get_money(@bank)
    else
      puts 'Ничья'
      @real_player.get_money(@bet)
      @bot_player.get_money(@bet)
    end

    clear_data

    if @real_player.money.zero? || @bot_player.money.zero?
      puts 'У одного из игроков закончились деньги. Хотите начать новую игру? "Да, Нет"'
      gets.chomp.capitalize == 'Да' ? start_game : exit
    end

    puts 'Хотите сыграть еще один раунд? "Да, Нет"'
    gets.chomp.capitalize == 'Да' ? start_round : exit
  end

  def calculate_score(cards)
    score = 0

    cards.each { |card| score += @card_deck.card_value(card) unless card.value == 'Т' }

    cards.count { |card| card.value == 'Т' }.times do
      score += score <= ACE_VALUE_CONDITION ? MAX_ACE : MIN_ACE
    end

    score
  end

  # Helpers
  def clear_data
    @card_deck = CardDeck.new
    @real_player.delete_cards
    @bot_player.delete_cards
    @bank = 0
  end

  # Creators
  def create_real_player
    puts 'Введите Ваше имя'
    name = gets.chomp

    @real_player = RealPlayer.new(name)
  end

  def create_bot_player
    @bot_player = BotPlayer.new
  end

  def create_card_deck
    @card_deck = CardDeck.new
  end
end
