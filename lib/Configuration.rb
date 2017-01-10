module Configuration
  def self.init
    puts "[ERROR] Can't find the configuration file." unless 
    File.exist?('./config/billy.yml')

    @config = begin
      YAML.load_file('./config/billy.yml')
    rescue ArgumentError => e
      puts "[ERROR] Can't parse YAML."
      puts "[ERROR] #{e.message}"
      exit
    end
  end

  def self.data
    @config
  end
end
