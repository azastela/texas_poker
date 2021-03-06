class Hand
  attr_accessor :cards, :id, :pairs

  def initialize(id = 0)
    @id = id
    @cards = []
    @all_cards = []
  end

  def draw(card)
    raise "Hand is full" if hand_is_full?
    @cards << card
    if hand_is_full?
      sort_cards!
    end
  end

  def count_rank(cards_from_deck = [])
    @all_cards = @cards + cards_from_deck
    @rank = get_rank
  end

  def draw_from(deck)
    draw(deck.deal)
  end

  def hand_is_full?
    @cards.length == 2
  end

  def high_card
    @all_cards.last
  end

  def highest_pair_value
    @pairs.keys.map {|k| Card.all_values[k]}.max
  end

  def rank
    return :empty_or_partial_hand unless hand_is_full?
    @rank
  end

  def to_s
    @all_cards.each { |card| card.to_s }
  end

  private
  def card_suits
    @all_cards.map { |card| card.suit }
  end

  def card_values
    @all_cards.map { |card| card.value }
  end

  def get_rank
    find_pairs
    # A straight from a ten to an ace with all five cards of the same suit. In poker all suits are ranked equally.
    return :royal_flush if is_flush? && has_all_royal_values?
    # Any straight with all five cards of the same suit.
    return :straight_flush if is_flush? && is_straight?
    # Any four cards of the same rank. If two players share the same Four of a Kind (on the board), the bigger fifth card (the "kicker") decides who wins the pot.
    return :four_of_a_kind if has_four_of_a_kind?
    # Any three cards of the same rank together with any two cards of the same rank. Our example shows "Aces full of Kings" and it is a bigger full house than "Kings full of Aces."
    return :full_house if is_full_house?
    # Any five cards of the same suit (not consecutive). The highest card of the five determines the rank of the flush. Our example shows an Ace-high flush, which is the highest possible.
    return :flush if is_flush?
    # Any five consecutive cards of different suits. Aces can count as either a high or a low card. Our example shows a five-high straight, which is the lowest possible straight.
    return :straight if is_straight? || is_sucker_straight?
    # Any three cards of the same rank. Our example shows three-of-a-kind Aces, with a King and a Queen as side cards - the best possible three of a kind.
    return :three_of_a_kind if has_three_of_a_kind?
    # Any two cards of the same rank together with another two cards of the same rank. Our example shows the best possible two-pair, Aces and Kings. The highest pair of the two determines the rank of the two-pair.
    return :two_pair if has_two_pair?
    # Any two cards of the same rank. Our example shows the best possible one-pair hand.
    return :one_pair if has_pair?
    # Any hand not in the above-mentioned hands. Our example shows the best possible high-card hand.
    :high_card
  end

  def sort_cards!
    @all_cards.sort! { |a, b| a.numeric_value <=> b.numeric_value }
  end

  def find_pairs
    @pairs = Hash.new(0)
    #gets the pairs and counts the number "of a kind"
    @all_cards.each { |c| @pairs[c.value] += 1 }
    @pairs.select! {|k,v| v > 1}
  end

  def is_flush?
    card_suits.uniq.length == 1
  end

  def is_straight?
    consecutive_card_count == 4
  end

  def is_sucker_straight?
    if @all_cards.last.value == :ace && @all_cards.first.value == :two && consecutive_card_count == 3
      @all_cards.unshift(@all_cards.pop) #move the Ace to the front of the hand
      return true
    end
    false
  end

  def consecutive_card_count
    consecutive_count = 0
    @all_cards.each_cons(2) { |card, next_card| consecutive_count += 1 if are_consecutive_cards?(card, next_card) }
    consecutive_count
  end

  def are_consecutive_cards?(card, next_card)
    card.numeric_value.succ == next_card.numeric_value
  end

  def has_all_royal_values?
    royal_values = [:ten, :jack, :queen, :king, :ace].to_set
    card_values.all? { |x| royal_values.include?(x) }
  end

  def n_of_a_kind?(number)
    @pairs.any? { |k, count| count > number - 1 }
  end

  def has_pair?
    n_of_a_kind?(2)
  end

  def has_three_of_a_kind?
    n_of_a_kind?(3)
  end

  def has_four_of_a_kind?
    n_of_a_kind?(4)
  end

  def has_two_pair?
    pairs_counted = @pairs.count { |_, pair| pair > 1 }
    pairs_counted > 1
  end

  def is_full_house?
    @pairs[0] == 2 && @pairs[1] == 3 || @pairs[0] == 3 && @pairs[1] == 2
  end
end