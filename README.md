# Billy

Billy is a simple discord bot built with [Discordrb](https://github.com/meew0/discordrb)

It has a basic plugin system 

Place plugins in /lib/plugins/


```
module SuperSimplePlugin
  extend Discordrb::EventContainer
  def self.info
    { name: 'Super Simple Plugin',
      author: 'xtda',
      version: '0.0.1' }
  end

  def self.init(_bot)

  end

  message with_text: "Hello Billy" do |event|
    event.respond "Hi, #{event.user.name}!"
  end
end

```

Enable in config

```
plugins:
  - Core
  - SuperSimplePlugin
```

The plugin is then auto loaded and enabled 


Currently it contains a few built in plugins

* Basic wow armory support
* Youtube music bot