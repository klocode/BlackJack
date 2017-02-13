require_relative 'deck'

class Shoe < Deck
  #changed create to deal so super looks for
  #the correct method
  def deal
    #set var shoe = to 7.times so we can
    #shuffle decks together
    shoe = 7.times { super }
    shoe.shuffle!
  end
end

# creates 7 decks and stores them in the deck array in blackjack.rb
