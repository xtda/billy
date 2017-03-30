require 'discordrb'

# setup bundler
require 'rubygems'
require 'bundler/setup'

# setup gems
require 'discordrb'
require 'json'
require 'yaml'
require 'fileutils'
require 'sequel'
require 'sqlite3'

$plugins = []

require_relative './Billy.rb'
require_relative './Configuration.rb'
require_relative './Database.rb'

Database.init
Configuration.init

Dir['./lib/plugins/*.rb'].each { |plugin| require plugin }

