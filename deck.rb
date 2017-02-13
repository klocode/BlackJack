require_relative 'card'

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    deal
    shuffle!
  end

  def draw
    cards.shift
  end

  def deal
    Card.suits.each do |s|
      Card.faces.each do |f|
        cards << Card.new(f, s)
      end
    end
  end

  def shuffle!
    cards.shuffle!
  end
end
