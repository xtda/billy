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
    armory_url = "http://#{region}.battle.net/wow/en/character/#{realm}/#{name}/advanced"
    event.respond "**Name:** #{character['name']}" \
    "\n**Class:** #{get_class(character['class'])}" \
    "\n**Faction:** #{get_faction(character['faction'])}" \
    "\n**iLVL:** #{character['items']['averageItemLevelEquipped']} (equipped) / #{character['items']['averageItemLevel']}  (max)" \
    "\n**Armory**: #{armory_url}"
  end

  def self.get_class(value)
    classes = ['Warrior', 'Paladin', 'Hunter', 'Rogue', 'Priest', \
               'Death Knight', 'Shaman', 'Mage', 'Warlock', \
               'Monk', 'Druid', 'Demon Hunter'].freeze
    classes.at(value - 1)
  end

  def self.get_faction(value)
    value.zero? ? 'Alliance' : 'Horde'
  end

end
