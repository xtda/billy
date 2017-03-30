module Overunder
  extend Discordrb::EventContainer
  extend Discordrb::Commands::CommandContainer
  def self.info
    { name: 'OverUnder',
      author: 'xtda',
      version: '0.0.1' }
  end

  def self.init(_bot)

  end


  command :ou, description: 'Play a game of over under', usage: '!ou under/over/seven' do |event, over|
    dice = roll_dice
    event.respond "Dice rolls: #{dice[0]} & #{dice[1]}\nTotal was: #{dice_total(dice)}\nRoll was: #{check_over_under(dice)}"
    return event.respond '**You Won**' if check_win(dice, over)
  end

  command :status do |event, *args|

  end

  def self.roll_dice
    Array.new(2) { 1 + SecureRandom.random_number(6) }
  end

  def self.dice_total(dice)
    dice.inject(0, :+)
  end

  def self.check_over_under(dice)
    total = dice_total(dice)
    return 'under' if total < 7
    return 'over' if total > 7
    return 'seven' if total == 7
  end

  def self.check_win(dice, option)
    return true if check_over_under(dice) == option
  end
end

