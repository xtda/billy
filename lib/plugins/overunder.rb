module Overunder
  extend Discordrb::EventContainer
  extend Discordrb::Commands::CommandContainer
  def self.info
    { name: 'OverUnder',
      author: 'xtda',
      version: '0.0.1' }
  end

  def self.init(_bot)
    @bot_channel = 'bot'
  end

  class OverUnderPlayer < Sequel::Model
    def self.find_player(id)
      find(discord_id: id) || create(discord_id: id)
    end

    def update_balance(balance, time = false)
      time ? update(balance: balance, last_reset: Time.now) : update(balance: balance)
    end
  end

  command [:ou, :under, :overunder, :over], min_args: 2, description: 'Play a game of over under', usage: '!ou under/over/seven', channels: ['bot'] do |event, over, bet|
    player = OverUnderPlayer.find_player(event.user.id)
    return event.respond 'noob' if player.balance < 1
    return event.respond "Bet must be lower than #{player.balance}" unless bet.to_i <= player.balance
    return event.respond 'Bet must be greater than 1' if bet.to_i < 1

    dice = roll_dice
    event.respond "Dice rolls: #{dice[0]} & #{dice[1]}\nTotal was: #{dice_total(dice)}\nRoll was: #{check_over_under(dice)}"
    if check_win(dice, over)
      win_amount = check_win_amount(over, bet.to_i)
      new_balance = (win_amount - bet.to_i) + player.balance
      response = "**You Won** #{win_amount}\n" \
                    "**New balance:** #{new_balance}"
    else
      new_balance = player.balance - bet.to_i
      response = "**You lost** #{bet.to_i}\n" \
                    "**New balance**: #{new_balance}"
    end
    player.update_balance(new_balance)
    event.respond "#{response}"
  end

  command :balance, channels: ['bot'] do |event|
    player = OverUnderPlayer.find_player(event.user.id)
    event.respond "Current balance: #{player.balance}"
  end

  def self.humanize(secs)
    [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
        if secs > 0
          secs, n = secs.divmod(count)
          "#{n.to_i} #{name}"
        end
    }.compact.reverse.join(' ')
  end

  command :give, channels: ['bot'] do |event|
    player = OverUnderPlayer.find_player(event.user.id)
    last_reset = ((Time.now - player.last_reset) / 3600)
    puts "Last requested: #{last_reset}"
    return event.respond "Please try again in #{humanize((108_00 - (Time.now - player.last_reset)))}" unless last_reset > 3
    new_balance = player.balance + 1_000_000
    player.update_balance(new_balance, true)
    event.respond "Your balance has been set to #{new_balance}"
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
    true if check_over_under(dice) == option
  end

  def self.check_win_amount(rolled, bet)
    return bet * 4 if rolled == 'seven'
    bet * 2
  end
end

