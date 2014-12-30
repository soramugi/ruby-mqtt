require 'thor'

module MQTT
  class Command < Thor
    class_option :mqtt_server, type: :string,  aliases: '-s'
    class_option :host,        type: :string,  aliases: '-h'
    class_option :port,        type: :numeric, aliases: '-P',  default: 1883
    class_option :username,    type: :string,  aliases: '-u'
    class_option :password,    type: :string,  aliases: '-p'
    class_option :ssl,         type: :boolean, default: false

    desc 'get [TOPIC]', 'getting topic.'
    def get(topic)
      client.get(topic) do |t,m|
        puts "topic:[#{t}] message:[#{m}]"
      end
    rescue Interrupt
      puts ''
      puts 'Bye.'
    end

    desc 'publish [TOPIC] [MESSAGE]', 'publish message.'
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
