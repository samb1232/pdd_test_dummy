require 'webrick'
require 'json'

server = WEBrick::HTTPServer.new(Port: 9292)

#
# @todo #2: pls work. TEST 123000
# 
server.mount_proc '/' do |req, res|
  if req.request_method == 'POST'
    puts "\n#{'=' * 50}"
    puts "🔔 Webhook Received at #{Time.now}"
    puts "#{'=' * 50}"
    
    event_type = req.header['x-github-event']&.first
    puts "Event Type: #{event_type || 'Unknown'}"
    
    puts "\nHeaders:"
    req.header.each do |key, value|
      puts "  #{key}: #{value.join(', ')}"
    end

    puts "\nPayload:"
    begin
      if req.body && !req.body.empty?
        # Attempt to parse and pretty-print JSON payload
        payload = JSON.parse(req.body)
        puts JSON.pretty_generate(payload)
      else
        puts "  (Empty Body)"
      end
    rescue JSON::ParserError
      # Fallback if it's not valid JSON
      puts req.body
    end
    
    puts "#{'=' * 50}\n"
    
    res.status = 200
    res.body = "Webhook received successfully"
  else
    res.status = 200
    res.body = "Server is running. Send a POST request to test the webhook."
  end
end

trap('INT') { server.shutdown }

puts "🚀 Starting GitHub Webhook listener on http://localhost:9292"
server.start
