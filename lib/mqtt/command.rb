require 'thor'

module MQTT
  class Command < Thor
    class_option :mqtt_server, type: :string,  aliases: '-s',  desc: 'Uri to be connected, Is priority.'
    class_option :host,        type: :string,  aliases: '-h'
    class_option :port,        type: :numeric, aliases: '-P',  default: 1883
    class_option :username,    type: :string,  aliases: '-u',  desc: 'Host and Port needs'
    class_option :password,    type: :string,  aliases: '-p',  desc: 'Host and Port needs'
    class_option :ssl,         type: :boolean, default: false, desc: 'Default: --no-ssl'

    desc 'get [TOPIC]', 'Getting topic.'
    def get(topic)
      client.get(topic) do |t,m|
        puts "topic:[#{t}] message:[#{m}]"
      end
    rescue Interrupt # Ctrl-c
      puts ''
      puts 'Bye.'
    end

    desc 'publish [TOPIC] [MESSAGE]', 'Publish message.'
    def publish(topic,message='')
      client.publish(topic, message.to_s.encode('UTF-8'))
      puts "success!  topic:[#{topic}] message:[#{message}]"
    end

    private

    def client
      MQTT::Client.connect(opt)
    end

    def opt
      if options[:mqtt_server]
        options[:mqtt_server]
      elsif options[:username] && options[:password]
        {
          host: options[:host],
          port: options[:port],
          username: options[:username],
          password: options[:password],
          ssl: options.ssl?,
        }
      elsif options[:host] && options[:port]
        {
          host: options[:host],
          port: options[:port],
          ssl: options.ssl?,
        }
      end
    end

  end
end
