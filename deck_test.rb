require 'minitest/autorun'

require_relative 'deck'

class DeckTest < MiniTest::Test

  def test_num_cards_in_deck
    deck = Deck.new
    assert_equal 52, deck.cards.length
    assert deck.cards.all?{|c| c.is_a? Card}
  end

  def test_gets_shuffled_when_created
    deck1 = Deck.new
    deck2 = Deck.new
    refute_equal deck1.cards, deck2.cards
  end

  def test_four_each_face_card
    deck = Deck.new
    faces = ("2".."10").to_a + %w(J Q K A)
    faces.each do |face|
      assert deck.cards.count{|card| card.face == face} == 4
    end
  end

  def test_thirteen_of_each_suit
    deck = Deck.new
    suits = %w(♣ ♠ ♢ ♡)
    suits.each do |suit|
      assert deck.cards.count { |card| card.suit.include?(suit)} == 13
    end
  end
end
