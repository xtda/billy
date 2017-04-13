module Fun
  extend Discordrb::EventContainer
  extend Discordrb::Commands::CommandContainer
  def self.info
    { name: 'Fun',
      author: 'xtda',
      version: '0.0.1' }
  end

  def self.init(_bot)
    @cat_fact_api_endpoint = 'https://catfacts-api.appspot.com/api/facts'.freeze
    @yo_momma_api_endpoint = 'http://api.yomomma.info/'.freeze
  end

  message contains: 'yo momma' do |event|
    request = RestClient.get(URI.encode(@yo_momma_api_endpoint))
    joke = JSON.parse(request)
    event.respond joke['joke']
  end

  command :catfact do |event|
    request = RestClient.get(URI.encode(@cat_fact_api_endpoint))
    fact = JSON.parse(request)
    event.respond "#{fact['facts'].first}"
  end

  message with_text: 'Hello Billy' do |event|
    event.respond "Hi, #{event.user.name}!"
  end

  message contains: /^Billy$/i do |event|
    event.respond 'what?'
  end

  message contains: /jewfish/i do |event|
    event.respond 'jewfish? did you mean Pharma?'
  end

  message with_text: 'woah clam down' do |event|
    event.respond "no you calm #{event.user.name}"
  end

  message with_text: 'mo bounce' do |event|
    event.respond 'Mo bounce in the motherfuckin\' house'
  end
end