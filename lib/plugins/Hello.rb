
module Hello
  def self.info
    { name: 'Hello',
      author: 'xtda',
      version: '0.0.1' }
  end

  def self.load(bot)
    bot.command :hello do |event|
      "Hello! #{event.user.name}"
    end
  end

end
