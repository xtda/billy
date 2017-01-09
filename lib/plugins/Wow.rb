module Wow
  extend Discordrb::Commands::CommandContainer
  def self.info
    { name: 'WoW Armory',
      author: 'xtda',
      version: '0.0.2' }
  end

  def self.init(bot)
    @api_key = Configuration.data['bnet_api_key']
  end

  command :wow, min_args: 1 do |event, params|
    "#{params}"
  end
end
