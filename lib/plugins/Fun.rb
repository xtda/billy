module Fun
  extend Discordrb::EventContainer
  extend Discordrb::Commands::CommandContainer
  def self.info
    { name: 'Fun',
      author: 'xtda',
      version: '0.0.1' }
  end

  def self.init(_bot)

  end

  def self.humanize(secs)
    [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
        if secs > 0
          secs, n = secs.divmod(count)
          "#{n.to_i} #{name}"
        end
    }.compact.reverse.join(' ')
  end

  command :d3 do |event|
    season_start = Time.new(2017, 04, 01, 11, 00, 00, '+11:00')
    current_time = Time.now()
    event.respond "D3 Season starts in: #{humanize((season_start - current_time).to_i)}"

  end

  message with_text: 'Hello Billy' do |event|
    event.respond "Hi, #{event.user.name}!"
  end

  message contains: /^Billy$/i do |event|
    event.respond 'what?'
  end

  message with_text: 'woah clam down' do |event|
    event.respond "no you calm #{event.user.name}"
  end

  message with_text: 'mo bounce' do |event|
    event.respond 'Mo bounce in the motherfuckin\' house'
  end
end