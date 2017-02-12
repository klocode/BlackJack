require_relative 'deck'

class Shoe < Deck
  def create
    7.times { super }
  end
end

# creates 7 decks and stores them in the deck array in blackjack.rb
