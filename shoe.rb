require_relative 'deck'

# creates 7 decks and stores them in the deck array in blackjack.rb
class Shoe < Deck
  def deal
    cards << 7.times { super }
    cards.shuffle!
  end
end
