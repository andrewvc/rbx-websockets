require "rubygems"
require "bundler/setup"
require 'eventmachine'
require 'em-websocket'
require 'agent'

Thread.abort_on_exception = true

ingress = Rubinius::Channel.new

400.times {|t|
  Thread.new {
    while recvd = ingress.receive
      ws, msg = recvd
      sleep rand(10)
      EM.schedule { ws.send "Thread #{t} got #{msg}" }
    end
  }
}

EventMachine.run {
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8000) do |ws|
    ws.onopen {
      puts "WebSocket connection open"
      ws.send "Hello Client"
    }
    ws.onclose { puts "Connection closed" }
    ws.onmessage {|msg|
      puts "Recieved message: #{msg}"
       
      ingress.send [ws,msg]
    }
  end
}

