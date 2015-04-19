class Game
  attr_reader :deck, :hands, :players

  def initialize(names = ["A","B"])
    initialize_players(names)
    initialize_hands
    @deck = Deck.new
  end

  def start
    deck.deal_visible_cards
    2.times {@hands.each {|hand| @deck.deal_to hand}}
  end

  private
  def initialize_players(names)
    @players = Hash.new(0)
    names.each { |name| @players[SecureRandom.uuid] = name }
  end

  def initialize_hands
    @hands = []
    @players.keys.each {|player| @hands << Hand.new(player) }
  end
end