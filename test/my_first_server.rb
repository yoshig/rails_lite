require 'webrick'

server = WEBrick::HTTPServer.new :Port => 8080, :DocumentRoot => '/'
trap('INT') { server.shutdown }

server.start

server.mount_proc '/' do |req, res|
  res.content_type = text/text
  res.body = req.path
end

