# frozen_string_literal: true

require_relative 'card_deck'
require_relative 'player'
require_relative 'real_player'
require_relative 'bot_player'

class Game
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

  def start_round
    puts "Ваша ставка - #{@bet}. Остаток на счету - #{@real_player.place_bet(@bet)}"
    puts "Ваши карты - #{@real_player.add_cards(@card_deck.deal_cards(2))}"
    puts "Сумма Ваших очков - #{calculate_score(@real_player.cards)}"
    puts "Ставка Дилера - #{@bet}. Остаток на счету - #{@bot_player.place_bet(@bet)}"
    @bot_player.add_cards(@card_deck.deal_cards(2))
    puts 'Карты Дилера - **'
    puts 'Сумма очков Дилера - **'
    @bank = 20
    puts "Банк - #{@bank}"
    menu
  end

  def calculate_score(cards)
    score = 0

    cards.each { |card| score += card_value(card) unless card.include?('Т') }

    cards.count { |card| card.include?('Т') }.times do
      score += score <= 10 ? 11 : 1
    end

    score
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

  def show_result
    real_player_score = calculate_score(@real_player.cards)
    bot_player_score = calculate_score(@bot_player.cards)

    puts 'Вскрываем карты'
    puts "Карты игрока - #{@real_player.cards}"
    puts "Карты Дилера - #{@bot_player.cards}"
    puts "Счет игрока - #{real_player_score}"
    puts "Счет Дилера - #{bot_player_score}"

    if (real_player_score > bot_player_score && real_player_score <= 21) ||
      (real_player_score < bot_player_score && bot_player_score > 21)
      puts "Поздравляем, #{@real_player.name}! Вы выиграли"
      @real_player.get_money(@bank)
    elsif bot_player_score <= 21
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

  def deal_card
    puts "Ваши карты - #{@real_player.add_card(@card_deck.deal_card)}"
    puts "Сумма Ваших очков - #{calculate_score(@real_player.cards)}"
    bot_player_turn
  end

  def clear_data
    @card_deck.refresh
    @real_player.delete_cards
    @bot_player.delete_cards
    @bank = 0
  end

  def card_value(card)
    { "2+": 2, "2<3": 2, "2^": 2, "2<>": 2,
      "3+": 3, "3<3": 3, "3^": 3, "3<>": 3,
      "4+": 4, "4<3": 4, "4^": 4, "4<>": 4,
      "5+": 5, "5<3": 5, "5^": 5, "5<>": 5,
      "6+": 6, "6<3": 6, "6^": 6, "6<>": 6,
      "7+": 7, "7<3": 7, "7^": 7, "7<>": 7,
      "8+": 8, "8<3": 8, "8^": 8, "8<>": 8,
      "9+": 9, "9<3": 9, "9^": 9, "9<>": 9,
      "10+": 10, "10<3": 10, "10^": 10, "10<>": 10,
      "В+": 10, "В<3": 10, "В^": 10, "В<>": 10,
      "Д+": 10, "Д<3": 10, "Д^": 10, "Д<>": 10,
      "К+": 10, "К<3": 10, "К^": 10, "К<>": 10,
      "Т+": 11, "Т<3": 11, "Т^": 11, "Т<>": 11 }[card.to_sym]
  end
end
