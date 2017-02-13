require 'minitest/autorun'
require_relative 'card'

class CardTest < MiniTest::Test
  def test_a_card_has_a_face_and_suit
    card = Card.new(8, '♡')
    assert_equal 8, card.face
    assert_equal '♡', card.suit
  end

  def test_a_card_should_determine_value
    card = Card.new('J', '♡')
    card2 = Card.new('Q', '♡')
    card3 = Card.new('K', '♡')
    card4 = Card.new('A', '♡')
    assert_equal 10, card.value
    assert_equal 10, card2.value
    assert_equal 10, card3.value
    assert_equal 11, card4.value
  end
end
