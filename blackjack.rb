require_relative 'deck'
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
    @deck = Shoe.new
    @prompt = TTY::Prompt.new
    @p1_hand = []
    @cpu_hand = []
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
    player_hand
    ace(p1_hand)
    player_move unless blackjack?(cpu_hand)
    dealer_hand
    dealer_move
    outcome
  end

# Game logic/setup

  def player_hand
    puts "You have a total of #{value(p1_hand)} "
    puts "Your hand is:"
    p1_hand.each do |card|
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
    until bust(p1_hand) || stay
      move = prompt.select("What would you like to do?", %w(Hit Stay)).downcase
      case move
      when "hit"
        p1_hand << deck.draw
        player_hand
      when "stay"
        puts "You're choosing to stay with a total of #{value(p1_hand)}."
        stay = true
      end
    end
  end

  def dealer_move
    stay = false
    until bust(cpu_hand) || blackjack?(p1_hand) || stay || bust(p1_hand)
      if value(cpu_hand) >= 16
      puts "Dealer stays with #{value(cpu_hand)}"
      stay = true
    elsif value(cpu_hand) < 16
        puts "Dealer hits"
        cpu_hand << deck.draw
        dealer_hand
      end
    end
  end

  def ace(hand)
    hand.each do |card|
      if card.face == "A"
        choice = prompt.select("What would you like the value to be?", %w(1 11))
        case choice
        when "1"
          card.value = 1
        when "11"
          card.value = 11
        end
      end
    end
  end


  # Compare methods

  def amount(hand)
    hand.length
  end

  def blackjack?(hand)
    amount(hand)== 2 && value(hand) == 21
  end

  def value(hand)
    hand.inject(0){|sum, card| sum + card.value}
  end

  def bust(hand)
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
      puts "You win! Ties go to the player"
      self.class.player_score += 1
    else
      puts "You won! You have more cards in your hand."
      self.class.player_score += 1
    end
  end


# Win conditions


  def outcome
    if !bust(p1_hand) && amount(p1_hand) == 6
      puts "You win!"
      self.class.player_score += 1
      ask_for_rematch
    elsif bust(p1_hand)
      puts "Sorry you busted, Dealer wins with #{value(cpu_hand)}"
      self.class.dealer_score += 1
      ask_for_rematch
    elsif bust(cpu_hand)
      puts "Dealer busted! You win!!"
      self.class.player_score += 1
      ask_for_rematch
    elsif amount(cpu_hand) == 2 && value(cpu_hand) == 21
      puts "You lost! Dealer got BlackJack!"
      self.class.dealer_score += 1
      ask_for_rematch
    elsif amount(p1_hand) == 2 && value(p1_hand) == 21
      puts "You win! You got BlackJack!"
      self.class.player_score += 1
      ask_for_rematch
    elsif value(p1_hand) > value(cpu_hand)
      puts "You win! You had a higher value than the Dealer."
      self.class.player_score += 1
      ask_for_rematch
    elsif value(cpu_hand) > value(p1_hand)
      puts "You lost! Dealer has higher value"
      self.class.dealer_score += 1
      ask_for_rematch
    elsif tie
      tie_breaker
      ask_for_rematch
    else
      puts "You win!"
      self.class.player_score += 1
      ask_for_rematch
    end
  end

  def ask_for_rematch
    desire = prompt.yes?("Would you like to play another hand?\n")
    if desire
      Game.new.play
    else
      puts "Thanks for playing, you have won #{self.class.player_score} games out of #{self.class.hands}. Dealer won #{self.class.dealer_score} games."
      exit
    end
  end
end

#write class method to keep tally every time game is run
#shoe new class and 7 super deck

Game.new.play
