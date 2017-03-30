module Database
  def self.init
    Dir.mkdir('./data') unless File.exist?('./data')
    Dir.mkdir('./data/migrations') unless File.exist?('./data/migrations')
    FileUtils.touch 'data/billy.db' unless File.exist?('data/billy.db')

    db = Sequel.connect('sqlite://data/billy.db')

    Sequel.extension :migration

    Sequel::Migrator.run(db, './data/migrations')
  end
end