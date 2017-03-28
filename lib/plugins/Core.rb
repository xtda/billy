module Core
  extend Discordrb::Commands::CommandContainer
  def self.info
    { name: 'Billy Core Plugin',
      author: 'xtda',
      version: '0.0.2' }
  end

  def self.init(bot)
    bot.set_user_permission(Configuration.data['discord_owner_id'], 999)
  end

  command :id do |event|
    event.user.id
  end

  command :plugins do |event|
    $plugins.map { |p| "#{p.info}" }.join(', ')
  end
end
