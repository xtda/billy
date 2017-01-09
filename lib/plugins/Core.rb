module Core
  extend Discordrb::Commands::CommandContainer
  def self.info
    { name: 'Billy Core Plugin',
      author: 'xtda',
      version: '0.0.2' }
  end

  def self.init(_bot)

  end

  command :id do |event|
    event.user.id
  end

end
