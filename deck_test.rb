require 'minitest/autorun'
require_relative 'blackjack'


class DeckTest < MiniTest::Test

  def setup
    @g = Game.new
  end

  def test_deck_is_shoe
    assert @g.deck.cards.length > 52
  end

end
