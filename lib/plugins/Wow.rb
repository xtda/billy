
module Wow
  def self.info
    { name: 'WoW Armory',
      author: 'xtda',
      version: '0.0.1' }
  end

  def self.init
    @api_key = Configuration.data['bnet_api_key']
  end

  def self.load(bot)
    init
    bot.command :wow, min_args: 1 do |event,params|
      "#{params}"
    end
  end

end
