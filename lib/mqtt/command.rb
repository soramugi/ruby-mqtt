require 'thor'
require 'yaml'

module MQTT
  class Command < Thor
    class_option :env,      type: :string,  aliases: '-e',  default: 'default',  desc: 'Environment, Is priority.'
    class_option :uri,      type: :string,  desc:    'Uri to be connected.'
    class_option :host,     type: :string,  aliases: '-h'
    class_option :port,     type: :numeric, aliases: '-P',  default: 1883
    class_option :username, type: :string,  aliases: '-u',  desc: 'Host and Port needs'
    class_option :password, type: :string,  aliases: '-p',  desc: 'Host and Port needs'
    class_option :ssl,      type: :boolean, default: false, desc: 'Default: --no-ssl'

    desc 'configration [ENV]', 'Configuration setting.'
    def configration(env=:default)
      opt = client_opt
      if ask('Setting type', ['uri', 'host']) == 'uri'
        # uri
        opt = ask('Uri to be connected.') unless opt.is_a?(String)
      else
        # host
        opt = {} unless opt.is_a?(Hash)
        host = opt[:host] || ask('Host')
        port = opt[:port] || ask('Port')
        opt.merge!(host: host)
        opt.merge!(port: port)
        if ask('Setting username and password ?', ['y', 'n']) == 'y'
          username = opt[:username] || ask('Username')
          password = opt[:password] || ask('Password')
          opt.merge!(username: username)
          opt.merge!(password: password)
        else
          opt.delete(:username)
          opt.delete(:password)
        end
      end
      generate_env(env,opt)
    rescue Interrupt # Ctrl-c
      puts ''
      puts 'Bye.'
    end

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
      puts 'success!'
    end

    private

    def client
      MQTT::Client.connect(client_opt)
    end

    def client_opt
      if File.exists?(env_path(options[:env]))
        YAML.load_file(env_path(options[:env]))
      elsif options[:uri]
        options[:uri]
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

    def env_path(env)
      File.join(Dir.home, '.ruby-mqtt', "#{env}.yml")
    end

    def generate_env(env,opts)
      dir = File.join(Dir.home, '.ruby-mqtt')
      Dir.mkdir(dir) unless File.exists?(dir)
      yml_file = File.join(dir, "#{env}.yml")
      open(yml_file,'w') do |f|
        YAML.dump(opts,f)
      end
      puts "Generate env #{yml_file}"
    end

    def get_stdin(message)
      print "#{message} : "
      STDIN.gets.chomp
    end

    def ask(message, selects=[])
      if selects.length > 0
        while true
          answer = get_stdin("#{message} [#{selects.join('/')}]")
          return answer if selects.include?(answer)
        end
      else
        get_stdin(message)
      end
    end

  end
end
