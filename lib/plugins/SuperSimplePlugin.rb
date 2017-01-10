module SuperSimplePlugin
  extend Discordrb::EventContainer
  def self.info
    { name: 'Super Simple Plugin',
      author: 'xtda',
      version: '0.0.1' }
  end

  def self.init(_bot)

  end

  message with_text: "Hello Billy" do |event|
    event.respond "Hi, #{event.user.name}!"
  end
end