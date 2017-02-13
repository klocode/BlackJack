require_relative 'shoe'
require_relative 'score'
require 'tty'

class Game
  extend Score

  attr_accessor :deck,
                :p1_hand,
                :cpu_hand,
                :prompt

  def initialize
    # little confusing to say that this is the deck, not a shoe..
    @deck = Shoe.new
    @prompt = TTY::Prompt.new
    @p1_hand = []
    @cpu_hand = []
    @details = 'You win!'
  end

  def deal
    2.times do
      @p1_hand << deck.draw
      @cpu_hand << deck.draw
    end
  end

  def play
    self.class.hands += 1
    deal
    # added the blackjack condition here because
    # it'll run this before checking player_hand
    # for blackjack
    blackjack?(cpu_hand)
    player_hand
    player_move # unless blackjack?(cpu_hand)
    dealer_hand
    dealer_move
    outcome
  end

  ### Game logic/setup

  def player_hand
    puts "You have a total of #{value(p1_hand)} "
    puts 'Your hand is:'
    p1_hand.each do |card|
      # how is this calling to_s?
      puts card
    end
    puts "The dealer currently showing is #{cpu_hand[1]}"
  end

  def dealer_hand
    puts "Dealer has a total of #{value(cpu_hand)}"
    cpu_hand.each do |card|
      puts card
    end
  end

  def player_move
    stay = false
    until bust?(p1_hand) || stay || blackjack?(p1_hand)
      move = prompt.select('What would you like to do?', %w(Hit Stay)).downcase
      case move
      when 'hit'
        p1_hand << deck.draw
        ace(p1_hand)
        player_hand
      when 'stay'
        puts "You're choosing to stay with a total of #{value(p1_hand)}."
        stay = true
      end
    end
  end

  def dealer_move
    stay = false
    until bust?(cpu_hand) || blackjack?(p1_hand) || stay || bust?(p1_hand)
      if value(cpu_hand) > 17
        puts "Dealer stays with #{value(cpu_hand)}"
        stay = true
      elsif value(cpu_hand) < 16
        puts 'Dealer hits'
        cpu_hand << deck.draw
        dealer_ace(cpu_hand)
        dealer_hand
      end
    end
  end

  def ace(hand)
    hand.each do |card|
      next unless card.face == 'A'
      choice = prompt.select('What would you like the value to be?', %w(1 11))
      case choice
      when '1'
        card.value = 1
      when '11'
        card.value = 11
      end
    end
  end

  # soft 17 not working (seems to work now) but what happens if I draw an ace later in the round??
  def dealer_ace(hand)
    hand.each do |card|
      next unless card.face == 'A'
      card.value = if value(hand) <= 17 || bust?(hand)
                     1
                   else
                     11
                   end
    end
  end

  ### Comparable methods
  def amount(hand)
    hand.length
  end

  def blackjack?(hand)
    amount(hand) == 2 && value(hand) == 21
  end

  def value(hand)
    hand.inject(0) { |sum, card| sum + card.value }
  end

  def bust?(hand)
    value(hand) > 21
  end

  def tie
    value(p1_hand) == value(cpu_hand)
  end

  def tie_breaker
    if amount(p1_hand) < amount(cpu_hand)
      puts "You lost! You have #{amount(p1_hand)} cards in your hand and dealer has #{amount(cpu_hand)} cards in their hand."
      self.class.dealer_score += 1
    elsif amount(p1_hand) == amount(cpu_hand)
      puts 'You win! Ties go to the player'
      self.class.player_score += 1
    else
      puts 'You won! You have more cards in your hand.'
      self.class.player_score += 1
    end
  end

  # set and display outcome of the game
  def outcome
    if player_wins?(p1_hand, cpu_hand) == true
      puts @details
      ask_for_rematch
    elsif cpu_wins?(p1_hand, cpu_hand) == true
      puts @details
      ask_for_rematch
    elsif tie
      tie_breaker
      ask_for_rematch
    else
      puts @details
      self.class.player_score += 1
      ask_for_rematch
    end
  end

  # winning conditions for player.
  def player_wins?(p1_hand, cpu_hand)
    if !bust?(p1_hand) && amount(p1_hand) == 6
      @details = 'You win!'
      self.class.player_score += 1
      true
    elsif bust?(cpu_hand)
      @details = 'Dealer busted! You win!!'
      self.class.player_score += 1
      true
    elsif amount(p1_hand) == 2 && value(p1_hand) == 21
      @details = 'You win! You got BlackJack!'
      self.class.player_score += 1
      true
    elsif value(p1_hand) > value(cpu_hand) && value(p1_hand) <= 21
      @details = 'You win! You had a higher value than the Dealer.'
      self.class.player_score += 1
      true
    else
      false
    end
  end

  # winning conditions for cpu
  def cpu_wins?(p1_hand, cpu_hand)
    if bust?(p1_hand)
      @details = "Sorry you busted, Dealer wins with #{value(cpu_hand)}"
      self.class.dealer_score += 1
      true
    elsif amount(cpu_hand) == 2 && value(cpu_hand) == 21
      @details = 'You lost! Dealer got BlackJack!'
      self.class.dealer_score += 1
      true
    elsif value(cpu_hand) > value(p1_hand) && value(cpu_hand) <= 21
      @details = 'You lost! Dealer has higher value'
      self.class.dealer_score += 1
      true
    else
      false
    end
  end

  def ask_for_rematch
    choice = prompt.yes?("Would you like to play another hand?\n")
    if choice
      Game.new.play
    elsif self.class.player_score > (2 * self.class.dealer_score)
      self.class.winner
    elsif self.class.player_score < (2 * self.class.dealer_score)
      self.class.loser
    else
      puts "Thanks for playing, you have won #{self.class.player_score} games out of #{self.class.hands}."
      exit
    end
  end
end

Game.new.play
