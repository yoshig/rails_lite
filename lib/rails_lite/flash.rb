require 'json'
require 'webrick'

class Flash < Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cook = req.cookies.find { |c| c.name == "_flash_message" }
    @req = cook || WEBrick::Cookie.new("_flash_message", '{}')
    @flash_index = req.cookies.find_index { |c| c.name == "_flash_message" }
  end

  def reset!(res)
    res.cookies.delete_at(@flash_index) if @flash_index
  end

  def store_flash(res)
    res.cookies << @req
  end
end
