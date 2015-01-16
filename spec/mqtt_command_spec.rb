$:.unshift(File.dirname(__FILE__))

require 'spec_helper'

describe MQTT::Command do
  def command(command_name,argument=[],options={})
    MQTT::Command.new.invoke(command_name, argument, options)
  end

  context "executing client" do

    before do
      expect(MQTT::Client).to receive(:connect).and_return(client)
    end

    describe :get do
      let(:topic) { 'one' }
      let(:message) { 'two' }
      let(:client) do
        client = double('client')
        expect(client).to receive(:get).and_yield(topic, message)
        client
      end
      it "should exec" do
        expect(command(:get, ['test'])).to eq nil
      end

      it "should display output" do
        output = "topic:[#{topic}] message:[#{message}]\n"
        expect { command(:get, ['test']) }.to output(output).to_stdout
      end
    end

    describe :publish do
      let(:client) do
        client = double('client')
        expect(client).to receive(:publish).and_return(20)
        client
      end

      it "should exec" do
        expect(command(:publish, ['test'])).to eq nil
      end

      it "should display output" do
        expect { command(:publish, ['test']) }.to output("success!\n").to_stdout
      end
    end

  end

  describe :configration do
    before do
      dir = File.join(File.dirname(__FILE__),'..','tmp')
      expect(Dir).to receive(:home).and_return(dir)
      Dir.mkdir(dir) unless File.exists?(dir)
    end

    context "Setting type uri" do
      before do
        expect(STDIN).to receive(:gets).and_return('uri', 'y')
      end

      it "should exec" do
        expect(command(:configration)).to eq nil
      end
      it "should display output" do
        expect { command(:configration) }.to output(/Generate env/).to_stdout
      end
    end
    context "Setting type host" do
      before do
        expect(STDIN).to receive(:gets).and_return('host', 'y', 'y', 'y', 'y', 'y')
      end

      it "should exec" do
        expect(command(:configration)).to eq nil
      end
      it "should display output" do
        expect { command(:configration) }.to output(/Generate env/).to_stdout
      end
    end
  end

end
