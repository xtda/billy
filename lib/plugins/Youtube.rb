require 'youtube-dl.rb'

module Youtube
  def self.info
    { name: 'Youtube Music Bot',
      author: 'xtda',
      version: '0.0.1' }
  end

  def self.init
    @is_joined = false
    @is_playing = nil
    @queue = Array.new()
    @voicebot = nil
    @is_paused = false
  end

  def self.load(bot)
    init
    bot.command(:youtube, min_args: 1, max_args: 2) do |event, param, url|
      case param
      when 'play'
        play(event, bot)
        break
      when 'pause'
        pause(event, bot)
        break
      when 'add'
        add(event, url)
      when 'remove'
        remove(event,url)
      when 'stop'
        break
      when 'skip'
        skip
        break
      when 'status'
        queue(event)
        break
      when 'queue'
        queue(event)
        break
      when 'join'
        join(event, bot)
        break
      when 'leave'
        leave(event, bot)
        break
      end
    end
  end

  def self.add(event, url)
    song = YoutubeDL.download url, extract_audio: true,
                                   output: './tmp/%(title)s.mp3',
                                   audio_format: 'mp3'
    data = { title: song.information[:title], filename: song.filename,
             added_by: event.user.name } 
    @queue.push(data)
    event.respond "Added **#{data[:title]}** to the queue."
  end

  def self.remove(event, number)
    if number == 'all'
      @queue = []
    else
      event.respond 'Removed song'
      @queue.delete_at(number.to_i-1) unless number.to_i == -1
    end
  end

  def self.queue(event)
    @is_playing ? response = "Now playing: **#{@is_playing[:title]}** added by #{@is_playing[:added_by]}" : response =  'Now playing: (nothing)'
    response = "#{response}\nCurrent queue: \n"
    i = 1
    @queue.each do |song|
      response = "#{response}#{i}. **#{song[:title]}** added by #{song[:added_by]}\n"
      i += 1
    end
    event.respond response
  end

  def self.play(event,bot)
    if @is_paused
      !@is_paused
      @voicebot.continue
      bot.game = "#{@is_playing[:title]}"
      return
    end
    begin
      song = @queue.shift
      @is_playing = song
      event.respond "Now playing: **#{song[:title]}** added by #{song[:added_by]}"
      bot.game = "#{song[:title]}"
      @voicebot.play_file(song[:filename])
    end until @queue.length.zero?
    @is_playing = nil
    bot.game = nil
    event.respond 'queue empty'
  end

  def self.pause(event, bot)
    @voicebot.pause
    @is_paused = true
    bot.game = "[paused] #{@is_playing[:title]}"
  end

  def self.skip
    @voicebot.stop_playing
  end

  def self.join(event, bot)
    if !event.user.voice_channel
      event.respond 'You are not in any voice channel'
      return
    end
    begin
      @voicebot = bot.voice_connect(event.user.voice_channel)
      @is_joined = true
    rescue Exception => e
      puts "[ERROR] #{e.message}"
      @is_joined = false
    end
    @voicebot.volume = 0.35
  end

  def self.leave(_event, bot)
    @voicebot.destroy
    @is_joined = false
    @is_playing = nil
    bot.game = nil
  end
end
