require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cook = req.cookies.find { |c| c.name == "_rails_lite_app" }
    @req = cook || WEBrick::Cookie.new("_rails_lite_app", '{}')
  end

  def [](key)
    JSON.parse(@req.value)[key]
  end

  def []=(key, val)
    new_hash = JSON.parse(@req.value)
    new_hash[key] = val
    @req.value = new_hash.to_json
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << @req
  end
end
