require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require 'debugger'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @session = session
    @params = Params.new(req)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    @res.body = content
    @res.content_type = type
    raise "You already rendered this page" if already_rendered?
    @already_built_response = @res
    @session.store_session(@res)
  end

  # helper method to alias @already_rendered
  def already_rendered?
    !!@already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    @res.header["location"] = url
    @res.status = 302
    raise "You already rendered this page" if already_rendered?
    @already_built_response = @res
    @session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore
    temp_file = File.read("views/#{controller_name}/#{template_name}.html.erb")
    puts temp_file
    temp_erb = ERB.new(temp_file).result(binding)
    render_content(temp_erb, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
  end
end
