require 'rbattlenet'

module Wow
  extend Discordrb::Commands::CommandContainer
  def self.info
    { name: 'WoW Armory',
      author: 'xtda',
      version: '0.0.2' }
  end

  def self.init(_bot)
    api_key = Configuration.data['bnet_api_key']
    RBattlenet.authenticate(api_key: api_key)
  end

  command :wow, min_args: 1 do |event, option, *args|
    case option

    when 'armory'
      return event.respond 'Usage: !wow armory name realm region(optional)' unless args.length > 1
      get_character(event, *args)
      break
    end
  end

  def self.get_character(event, name, realm, region = 'us')
    RBattlenet.set_region(region: region, locale: 'en_US')
    character = RBattlenet::Wow::Character.find(name: name, realm: realm,
                                                fields: %w(items progression))

    return event.respond 'Character not found!' if character['status'] == 'nok'

    event.respond "**Name:** #{character['name']}"
    event.respond "**Class:** #{get_class(character['class'])}"
    event.respond "**Faction:** #{get_faction(character['faction'])}"
    event.respond "**iLVL:** (equipped) #{character['items']['averageItemLevelEquipped']} / (max) #{character['items']['averageItemLevel']}"
  end

  def self.get_class(value)
    possible_outcomes = {
      1 => 'Warrior',
      2 => 'Paladin',
      3 => 'Hunter',
      4 => 'Rogue',
      5 => 'Priest',
      6 => 'Death Knight',
      7 => 'Shaman',
      8 => 'Mage',
      9 => 'Warlock',
      10 => 'Monk',
      11 => 'Druid',
      12 => 'Demon Hunter'
    }
    possible_outcomes[value]
  end

  def self.get_faction(value)
    value.zero? ? 'Alliance' : 'Horde'
  end

end
