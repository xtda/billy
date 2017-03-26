require 'rest-client'
require 'json'


module Wow
  extend Discordrb::Commands::CommandContainer
  def self.info
    { name: 'WoW Armory',
      author: 'xtda',
      version: '0.0.2' }
  end

  def self.init(_bot)
    @api_key = Configuration.data['bnet_api_key']

  end

  command :armory, min_args: 2,max_args: 3, description: 'Search the armory for a player', usage: '!armory name realm region(option)' do |event, *args|
    get_character(event, *args)
  end

  def self.get_character(event, name, realm, region = 'us')
    uri = URI::encode("https://#{region}.api.battle.net/wow/character/#{realm}/#{name}?fields=items,progression,guild,achievements&apikey=#{@api_key}")
    request = RestClient.get(uri)
    character = JSON.parse(request)

    armory_url = "http://#{region}.battle.net/wow/en/character/#{realm}/#{name}/advanced"
    wowprogress_url = "http://www.wowprogress.com/character/#{region}/#{realm}/#{name}"

    return event.respond 'Character not found!' if character['status'] == 'nok'
    event.respond "**Details:**\n\n" \
    "**Name:** #{character['name']}" \
    "\n**Guild:** #{character['guild']['name']}" \
    "\n**Class:** #{get_class(character['class'])}" \
    "\n**Faction:** #{get_faction(character['faction'])}" \
    "\n**iLVL:** #{character['items']['averageItemLevelEquipped']} (equipped) / #{character['items']['averageItemLevel']}  (max)" \
    "\n\n**Progression:**\n\n#{get_progression(character['progression'])}" \
    "\n**Armory**: #{armory_url}" \
    "\n**Wowprogress**: #{wowprogress_url}"
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

  def self.get_progression(armory_progression)
    progression = ''

    valid_raids = [
      'The Emerald Nightmare',
      'Trial of Valor',
      'The Nighthold'
    ].freeze

    armory_progression['raids'].each do |raid|
      valid_raids.each do |raids|
        if raid['name'] == raids
          raid['bosses'].each do |boss|
            if boss['mythicKills'] >= 1
              @mythic_progress += 1
            end
            if boss['heroicKills'] >= 1
              @heroic_progress += 1
            end
            if boss['normalKills'] >= 1
              @normal_progress += 1
            end
          end
        progression += "**#{raid['name']}:** (N) #{@normal_progress} / #{raid['bosses'].length} (H) #{@heroic_progress} / #{raid['bosses'].length} (M) #{@mythic_progress} / #{raid['bosses'].length}\n"
        end
      end
      @normal_progress = 0
      @heroic_progress = 0
      @mythic_progress = 0
    end
    progression
  end
end
