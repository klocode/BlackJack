require_relative 'deck'

class Shoe < Deck
  #changed create to deal so super looks for
  #the correct method
  def deal
    7.times { super }
    # shoe.shuffle!
  end

  # def shuffle!
  #   cards.shuffle!
  # end
end

# creates 7 decks and stores them in the deck array in blackjack.rb
