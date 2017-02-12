require_relative 'deck'
require_relative 'shoe'
require 'tty'

class Game

  attr_accessor :deck,
                :p1_hand,
                :cpu_hand,
                :top_card,
                :prompt

  def initialize
    @deck = Shoe.new
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
    player_move unless black_jack
    dealer_hand
    dealer_move
    outcome
  end

  def player_amount
    p1_hand.length
  end

  def cpu_amount
    cpu_hand.length
  end

  def black_jack
    case
    when player_value == 21 && player_amount == 2 then true
    when dealer_value == 21 && cpu_amount == 2 then true
    else false
    end
  end

  def player_hand
    puts "You have a total of #{player_value} "
    puts "You have #{player_amount} cards in your hand: "
    p1_hand.each do |card|
      puts card
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


  def player_move
    stay = false
    until player_bust || stay
      move = prompt.select("What would you like to do?", %w(Hit Stay)).downcase
      case move
      when "hit"
        p1_hand << deck.draw
        player_hand
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

  def dealer_move
    stay = false
    until dealer_bust || black_jack || stay || player_bust
      if dealer_value >= 16
      puts "Dealer stays with #{dealer_value}"
      stay = true
      elsif dealer_value < 16
        puts "Dealer hits"
        cpu_hand << deck.draw
        dealer_hand
      end
    end
  end

  def tie
    player_value == dealer_value
  end

  def tie_breaker
    if p1_hand.length < cpu_hand.length
      puts "You lost! You have #{player_amount} cards in your hand and dealer has #{cpu_hand.length} cards in their hand."
    elsif p1_hand.length == cpu_hand.length
      puts "You win! Ties go to the player"
    else
      puts "You won! You have more cards in your hand."
    end
  end


  def outcome
    if player_amount == 6 && player_value < 21
      puts "You win!"
      ask_for_rematch
    elsif player_bust
      puts "Sorry you busted, Dealer wins with #{dealer_value}"
      ask_for_rematch
    elsif dealer_bust
      puts "Dealer busted! You win!!"
      ask_for_rematch
    elsif cpu_amount == 2 && dealer_value == 21
      puts "You lost! Dealer got BlackJack!"
      ask_for_rematch
    elsif player_amount == 2 && player_value == 21
      puts "You win! You got BlackJack!"
      ask_for_rematch
    elsif player_value > dealer_value
      puts "You win! You had a higher value than the Dealer."
      ask_for_rematch
    elsif dealer_value > player_value
      puts "You lost! Dealer has higher value"
      ask_for_rematch
    elsif tie
      tie_breaker
      ask_for_rematch
    else
      puts "You win!"
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

#write class method to keep tally every time game is run
#shoe new class and 7 super deck

Game.new.play
