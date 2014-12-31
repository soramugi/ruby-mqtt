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
    def configration(env=nil)
      env = env || options[:env]
      opt = {}
      if ask('Setting type', ['uri', 'host']) == 'uri'
        # uri
        opt = ask('Uri to be connected.', options[:uri])
      else
        # host
        opt.merge!(host: ask('Host', options[:host]))
        opt.merge!(port: ask('Port', options[:port]))
        if ask('Setting username and password ?', ['y', 'n']) == 'y'
          opt.merge!(username: ask('Username', options[:username]))
          opt.merge!(password: ask('Password', options[:password]))
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

    no_commands do
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
        yml_file = env_path(env)
        dir = File.dirname(yml_file)
        Dir.mkdir(dir) unless File.exists?(dir)
        open(yml_file,'w') do |f|
          YAML.dump(opts,f)
        end
        puts "Generate env #{yml_file}"
      end

      def get_stdin(message)
        print "#{message} : "
        STDIN.gets.chomp
      end

      def ask(message, select=[])
        if select.is_a?(Array) && select.length > 0
          while true
            answer = get_stdin("#{message} [#{select.join('/')}]")
            return answer if select.include?(answer)
          end
        elsif select != []
          answer = get_stdin("#{message} [Default: #{select}]")
          return answer == '' ? select : answer
        else
          get_stdin(message)
        end
      end
    end

  end
end
