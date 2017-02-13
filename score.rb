module Score
  attr_writer :hands, :player_score, :dealer_score

  def hands
    @hands ||= 0
  end

  def player_score
    @player_score ||= 0
  end

  def dealer_score
    @dealer_score ||= 0
  end

  def winner
    puts "You've won #{@player_score} out of #{@hands}. Cash you ousside, how bou dah?"
  end

  def loser
    puts 'GTFO'
  end
end
