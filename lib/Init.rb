require 'discordrb'

# setup bundler
require 'rubygems'
require 'bundler/setup'

# setup gems
require 'discordrb'
require 'json'
require 'yaml'
require 'fileutils'

$plugins = []

require_relative './Billy.rb'
require_relative './Configuration.rb'

Dir['./lib/plugins/*.rb'].each { |plugin| require plugin }
Configuration.init
