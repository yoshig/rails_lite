require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    query_string = parse_www_encoded_form(req.query_string) if req.query_string
    body = parse_www_encoded_form(req.body) if req.body
    @params = route_params.merge(query_string || {}).merge(body || {})
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @allowed ||= []
    keys.each { |key| @allowed << key }
  end

  def require(key)
    raise Params::AttributeNotFoundError unless @params.include?(key)
  end

  def permitted?(key)
    @allowed.include?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    {}.tap do |queries|
      URI.decode_www_form(www_encoded_form).each do |q, subj|
        q_array = parse_key(q)
        arr_to_nested_hash(queries, q_array, subj)
      end
    end
  end

  def arr_to_nested_hash(queries, array, final_ans)
    nester = queries
    until array.empty?
      new_q = array.shift
      nester[new_q] = final_ans if array.empty?

      if nester.include?(new_q)
        nester = nester[new_q]
      else
        nester[new_q] = {}
        nester = nester[new_q]
      end
    end
    queries
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.gsub("]", "").split("[")
  end
end
