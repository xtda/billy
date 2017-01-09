class Billy
  def initialize

    @bot = Discordrb::Commands::CommandBot.new token: Configuration.data['discord_token'],
                                               client_id: Configuration.data['discord_application_id'],
                                               prefix: Configuration.data['command_prefix']

    Configuration.data['plugins'].each do |p|
      $plugins.push(p.constantize)
    end
    load_plugins
  end

  def run
    @bot.run :async
  end

  def stop
    @bot.stop
  end

  def load_plugins
    $plugins.each do |plugin|
      @bot.include! plugin
      plugin.init(@bot)
    end
  end
end
