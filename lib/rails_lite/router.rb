class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, = pattern, http_method
    @controller_class, @action_name = controller_class, action_name

  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    begin
      @match = @pattern.match(req.path.downcase)
      @match && @http_method.to_s.match(req.request_method.to_s)
    rescue
      false
    end
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    if matches?(req)
      match_hash = Hash[@match.names.map(&:to_sym).zip(@match.captures)]
      debugger
      @controller_class.new(req, res, match_hash).invoke_action(@action_name)
      res.body
    end
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    Object.instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |*args|
      add_route(*args, http_method)
    end
  end

  # should return the route that matches this request
  def match(req)
    @routes.find { |route|  route.matches?(req) }
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    if route = self.match(req)
      route.run(req, res)
    else
      res.status = 404
    end
  end
end
