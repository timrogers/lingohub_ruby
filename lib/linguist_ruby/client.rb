require 'rest_client'
require 'uri'
require 'time'
require 'linguist_ruby/version'
require 'vendor/okjson'
require 'json'
require 'linguist/models/projects'

# A Ruby class to call the Linguist REST API.  You might use this if you want to
# manage your Linguist apps from within a Ruby program, such as Capistrano.
#
# Example:
#
#   require 'linguist'
#   linguist = Linguist::Client.new('me@example.com', 'mypass')
#   linguist.create('myapp')
#
class Linguist::Client

  def self.version
    Linguist::VERSION
  end

  def self.gem_version_string
    "linguist-gem/#{version}"
  end

  attr_accessor :host, :user, :password

  def self.auth(options)
    client = new(options)
    OkJson.decode client.post('/sessions', {}, :accept => 'json').to_s
  end

  def initialize(options)
    @user       = options[:username]
    @password   = options[:password]
    @auth_token = options[:auth_token]
    @host       = options[:host] || 'lingui.st'
  end

  def credentials
    @auth_token.nil? ? {:username => @user, :password => @password} : {:username => @auth_token, :password => ""}
  end

  def project(title)
    project = self.projects[title]
    raise(Linguist::Command::CommandFailed, "=== You aren't associated for a project named '#{title}'") if project.nil?
    project
  end

  def projects
    return Linguist::Models::Projects.new(self)
  end

  def get(uri, extra_headers={ }) # :nodoc:
    process(:get, uri, extra_headers)
  end

  def post(uri, payload="", extra_headers={ }) # :nodoc:
    process(:post, uri, extra_headers, payload)
  end

  def put(uri, payload, extra_headers={ }) # :nodoc:
    process(:put, uri, extra_headers, payload)
  end

  def delete(uri, extra_headers={ }) # :nodoc:
    process(:delete, uri, extra_headers)
  end

  def process(method, uri, extra_headers={ }, payload=nil)
    headers = linguist_headers.merge(extra_headers)
#    payload  = auth_params.merge(payload)
    args     = [method, payload, headers].compact
    response = resource(uri, credentials).send(*args)

#    extract_warning(response)
    response
  end

  def resource(uri, credentials)

    RestClient.proxy = ENV['HTTP_PROXY'] || ENV['http_proxy']
    if uri =~ /^https?/
#      RestClient::Resource.new(uri, user, auth_token)
      RestClient::Resource.new(uri, :user => credentials[:username], :password => credentials[:password])
    elsif host =~ /^https?/
#      RestClient::Resource.new(host, user, auth_token)[uri]
      RestClient::Resource.new(host, :user => credentials[:username], :password => credentials[:password])[uri]
    else
#      RestClient::Resource.new("https://api.#{host}", user, password)[uri]
#      RestClient::Resource.new("http://localhost:3000/api/v1", user, auth_token)[uri]
      RestClient::Resource.new("http://localhost:3000/api/v1", :user => credentials[:username], :password => credentials[:password])[uri]
    end
  end

  def extract_warning(response)
#    return unless response
#    if response.headers[:x_heroku_warning] && @warning_callback
#      warning             = response.headers[:x_heroku_warning]
#      @displayed_warnings ||= { }
#      unless @displayed_warnings[warning]
#        @warning_callback.call(warning)
#        @displayed_warnings[warning] = true
#      end
#    end
  end

  def linguist_headers # :nodoc:
    {
      'X-Linguist-API-Version'     => '1',
      'User-Agent'                 => self.class.gem_version_string,
      'X-Ruby-Version'             => RUBY_VERSION,
      'X-Ruby-Platform'            => RUBY_PLATFORM,
      'content_type'               => 'json',
      'accept'                     => 'json'
    }
  end

end