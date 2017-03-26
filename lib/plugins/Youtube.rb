require 'json'
require 'open3'

module Youtube
  extend Discordrb::Commands::CommandContainer
  def self.info
    { name: 'Youtube Music Bot',
      author: 'xtda',
      version: '0.0.2' }
  end                                                     

  def self.init(bot)
    @is_joined = false
    @is_playing = nil
    @queue = []
    @voicebot = nil
    @is_paused = false
    @bot = bot
   #@voicebot.volume = 0.35
  end

  command :play do |event, *args|
    search = args.join(' ')
    return event.respond 'I am not currently on any channel type !join to make me join' unless @is_joined
    find_video(event, search)
  end

  command :add, help_available: false do |event,url|
    add(event, url)
  end

  command :skip, help_available: false do |event|
    skip(event)
  end

  command :pause, help_available: false do
    pause_music
  end

  command :join, help_available: false do |event|
    join(event)
  end

  command :leave, help_available: false do
    leave
  end

  command :queue, help_available: false do |event|
    queue(event)
  end

  command :status, help_available: false do |event|
    status(event)
  end

  command :remove, help_available: false do |event,id|
    remove(event, id)
  end

  command :volume, help_available: false do |event,vol|
    set_volume(event, vol)
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

  def self.find_video(event, url)
    cmd = "./vendor/bin/youtube-dl -x -o './tmp/%(title)s.mp3' --audio-format 'mp3' ytsearch:\"#{url}\" --no-color --no-progress  --print-json"
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      if wait_thr.value.success?
        @song = JSON.parse(stdout.read.to_s, symbolize_names: true)
        data = { title: @song[:title], filename: @song[:_filename],
               added_by: event.user.name }
        @queue.push(data)
        event.respond "Added **#{data[:title]}** to the queue."
      end
    end
    play(event) unless @is_playing
  end

  def self.remove(event, number)
    if number == 'all'
      @queue = []
    else
      event.respond 'Removed song'
      @queue.delete_at(number.to_i-1) unless number.to_i == -1
    end
  end

  def self.set_volume(event, vol)
    @voicebot.volume = vol.to_f
    event.respond "Volume set to #{vol}"
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

  def self.play(event)
    if @is_paused
      !@is_paused
      @voicebot.continue
      @bot.game = "#{@is_playing[:title]}"
      return
    end
    loop do
      song = @queue.shift
      @is_playing = song
      event.respond "Now playing: **#{song[:title]}** added by #{song[:added_by]}"
      @bot.game = "#{song[:title]}"
      @voicebot.play_file(song[:filename])
      break if @queue.length.zero?
    end
    @is_playing = nil
    @is_paused = true
    @bot.game = nil
    event.respond 'queue empty'
  end

  def self.pause_music
    @voicebot.pause
    @is_paused = true
    @bot.game = "[paused] #{@is_playing[:title]}"
  end

  def self.skip(event)
    @voicebot.stop_playing
    event.respond 'Skipping song'
  end

  def self.join(event)
    if !event.user.voice_channel
      event.respond 'You are not in any voice channel'
      return
    end
    begin
      @voicebot = @bot.voice_connect(event.user.voice_channel)
      @is_joined = true
    rescue StandardError => e
      puts "[ERROR] #{e.message}"
      @is_joined = false
    end
    event.respond 'Joined channel'
  end

  def self.leave
    @voicebot.destroy
    @is_joined = false
    @is_playing = nil
    @bot.game = nil
  end
end
