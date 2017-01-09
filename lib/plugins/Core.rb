module Core
  def self.info
    { name: 'Billy Core Plugin',
      author: 'xtda',
      version: '0.0.1' }
  end

  def self.load(bot)
    bot.command :about do |event|
      'Billy version 0.0.1!'
    end

    bot.command :id do |event|
      "#{event.user.id}"
    end

    bot.command :plugins do |event|
      $plugins.map { |p| "#{p.info}" }.join(', ')
    end
  end
end
