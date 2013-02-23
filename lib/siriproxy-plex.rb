require 'cora'
require 'siri_objects'
require 'pp'
require 'open-uri'

#######
# This is a plugin providing basic control over Plex media players. Only bothers with a few commands,
# because who wants to say "down, down, select, down, no up, right, play"?
#
# Key phrases are:
#
#   "play film <film>"
#       Doesn't do any clever searching, it simply greps for a matching 'title' attribute
#       in http://<plex server>/library/sections/2/all/
#       This works better than you'd think, most likely because Apple's transcription 'knows' about film names.
#
#   "plex play/pause"
#       Pause or resume the current video
#
# Remember to add this plugin to the "config.yml" file
######

class SiriProxy::Plugin::Example < SiriProxy::Plugin
    def initialize(config)
        #if you have custom configuration options, process them here!
    end

    #
    # Configure your Plex setup here
    #
    plex_server = "plex-media-server" # central plex server
    plex_player = "plex-media-player" # plex media player
    plex_port   = "32400" # default port

    #get the user's location and display it in the logs
    #filters are still in their early stages. Their interface may be modified
    filter "SetRequestOrigin", direction: :from_iphone do |object|
        puts "[Info - User Location] lat: #{object["properties"]["latitude"]}, long: #{object["properties"]["longitude"]}"

        #Note about returns from filters:
        # - Return false to stop the object from being forwarded
        # - Return a Hash to substitute or update the object
        # - Return nil (or anything not a Hash or false) to have the object forwarded (along with any
        #    modifications made to it)
    end

    # Play a film
        # "play film <film>" or "plex film <film>"
    listen_for /(?:plex|play) film (.*)/i do |film|
        puts "Got film name '#{film}'"
        film =~ /([a-zA-Z0-9\s]*)\s/
        filmname = $1
        puts "also searching for '#{filmname}'"

        # fetch movie list
        begin
            f = open("http://192.168.1.150:32400/library/sections/2/all/")
            rescue StandardError
                say "Unable to fetch film list from Plex server"
                request_completed
                return
        end

        text = f.read
        if text =~ / key="(.*)" studio=".*" type="movie" title="#{filmname}/i then
            puts "Found matching film: '#{$1}'"

            plex_cmd = "curl -m 5 -s -S 'http://#{plex_server}:#{plex_port}/system/players/#{plex_player}/application/playMedia?key=#{$1}&path=http://#{plex_server}:#{plex_port}#{$1}'"
            curl_error = `#{plex_cmd}`

            # check for errors executing command
            if curl_error == ""
                say "Playing #{film}"
            else
                say curl_error
            end
        else
            say "Couldn't find #{film}"
        end

        request_completed
    end

    # Resume playback
        # "plex play" or "plex resume"
    listen_for /plex (play|resume)/i do
        plex_cmd = "curl -m 3 -s -S http://#{plex_server}:#{plex_port}/system/players/#{plex_player}/playback/play 2>&1"
        curl_error = `#{plex_cmd}`

        if curl_error == ""
            say "Resuming plex"
        else
            say curl_error
        end

        request_completed
    end

    # Pause playback
        # "plex pause" (also catches Siri's verbal typos)
    listen_for /plex (pause|pools|calls|cause)/i do
        plex_cmd = "curl -m 3 -s -S http://#{plex_server}:#{plex_port}/system/players/#{plex_player}/playback/pause 2>&1"
        curl_error = `#{plex_cmd}`

        if curl_error == ""
            say "Pausing plex"
        else
            say curl_error
        end

        request_completed
    end

    listen_for /test siri plex/i do
        say "Siri Proxy Plex plugin is up and running!"

        request_completed
    end

end
