module Eightball
  extend Discordrb::EventContainer
  extend Discordrb::Commands::CommandContainer
  def self.info
    { name: 'Magic Eight Ball',
      author: 'xtda',
      version: '0.0.1' }
  end

  def self.init(_bot)

  end

  def self.possible_answers
    [
      'It is certain',
      'It is decidedly so',
      'Without a doubt',
      'Yes definitely',
      'You may rely on it',
      'As I see it, yes',
      'Most likely',
      'Outlook good',
      'Yes',
      'Signs point to yes',
      'Reply hazy try again',
      'Ask again later',
      'Better not tell you now',
      'Cannot predict now',
      'Concentrate and ask again',
      'Don\'t count on it',
      'My reply is no',
      'My sources say no',
      'Outlook not so good',
      'Very doubtful'
    ]
  end

  command :fortune do |event|
    event.respond "**#{possible_answers[SecureRandom.random_number(possible_answers.size)]}**"
  end
end