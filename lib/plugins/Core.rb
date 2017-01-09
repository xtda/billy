module Core
  extend Discordrb::Commands::CommandContainer
  def self.info
    { name: 'Billy Core Plugin',
      author: 'xtda',
      version: '0.0.1' }
  end

  def self.init

  end

  command :id do |event|
    event.user.id
  end

end
