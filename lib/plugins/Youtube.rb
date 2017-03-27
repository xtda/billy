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
    @youtube_dl_bin = Configuration.data['youtube_dl_location']
  end

  command :play , description: 'Add a song to queue', usage: '!play <link to youtube video> or search string' do |event, *args|
    search = args.join(' ')
    return event.respond 'I am not currently on any channel type !join to make me join' unless @is_joined
    if @is_paused
      play(event)
    else
      find_video(event, search)
    end
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

  command :leave, help_available: false do |event|
    leave(event)
  end

  command :queue, help_available: false do |event|
    queue(event)
  end

  command :remove, help_available: false do |event, id|
    remove(event, id)
  end

  command :volume, help_available: false do |event, vol|
    set_volume(event, vol)
  end

  def self.find_video(event, url)
    url.include?('https://www.youtube.com/') ? search = "#{url}" : search = "ytsearch:\"#{url}\""
    cmd = "#{@youtube_dl_bin} -x -o './tmp/%(title)s.mp3' --audio-format 'mp3' --no-color --no-progress --no-playlist --print-json -f bestaudio/best --restrict-filenames -q --no-warnings -i --no-playlist #{search}"
    Open3.popen3(cmd) do |_stdin, stdout, _stderr, wait_thr|
      if wait_thr.value.success?
        song = JSON.parse(stdout.read.to_s, symbolize_names: true)
        data = { title: song[:title], filename: song[:_filename],
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
      @queue.delete_at(number.to_i - 1) unless number.to_i == -1
      event.respond 'Removed song'
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

  def self.leave(event)
    @queue = []
    @voicebot.destroy
    @is_joined = false
    @is_playing = nil
    @bot.game = nil
    event.respond 'Left channel'
  end
end
