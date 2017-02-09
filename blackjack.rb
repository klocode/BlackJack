require_relative 'deck'
require 'tty'

class Game

  attr_accessor :deck,
                :p1_hand,
                :cpu_hand,
                :top_card,
                :prompt

  def initialize
    @deck = Deck.new
    @prompt = TTY::Prompt.new
    @p1_hand = []
    @cpu_hand = []
    2.times do
      @p1_hand << deck.draw
      @cpu_hand << deck.draw
    end
  end

  def play
    player_hand
    hit_or_stay
    dealer_hand
    dealer_move
    outcome

  end

  def player_hand
    puts "You have a total of #{player_value}: "
    p1_hand.each do |card|
      print card
    end
    puts "The dealer currently showing is #{cpu_hand[1]}"
  end

  def dealer_hand
    puts "Dealer has a total of #{dealer_value}"
    cpu_hand.each do |card|
      puts card
    end
  end

  def player_value
    p1_hand.inject(0){|sum, card| sum + card.value}
  end

  def dealer_value
    cpu_hand.inject(0){|sum, card| sum + card.value}
  end

  def hit_or_stay
    stay = false
    until player_bust || stay
      move = prompt.select("What would you like to do?", %w(Hit Stay)).downcase
      case move
      when "hit"
        p1_hand << deck.draw
        player_hand
        puts "You now have a total of #{player_value}"
      when "stay"
        puts "You're choosing to stay with a total of #{player_value}."
        stay = true
      end
    end
  end

  def player_bust
    player_value > 21
  end

  def dealer_bust
    dealer_value > 21
  end

  def black_jack
    dealer_value == 21
  end

  def dealer_move
    stay = false
    until dealer_bust || black_jack || stay || player_bust
      if dealer_value > 16
      puts "Dealer stays with #{dealer_value}"
      stay = true
      elsif dealer_value < 16
        puts "Dealer hits"
        @cpu_hand << deck.draw
        puts "Dealer now has a total of #{dealer_value}"
      end
    end
  end

  def outcome
    if player_bust
      puts "Sorry you busted, Dealer wins with #{dealer_value}"
      ask_for_rematch
    elsif black_jack
      puts "Dealer won! Dealer got blackjack!"
      ask_for_rematch
    elsif dealer_bust
      puts "Dealer busted! You win!!"
      ask_for_rematch
    elsif player_value > dealer_value
      puts "You win!"
      ask_for_rematch
    else
      puts "You win"
      ask_for_rematch
    end
  end

  def ask_for_rematch
    desire = prompt.yes?("Would you like to play another hand?")
    if desire
      Game.new.play
    else
      puts "Goodbye."
      exit
    end
  end
end


Game.new.play
