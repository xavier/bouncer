
class Bouncer

  # See configure for available options
  def initialize(app, options = {})
    @app = app
    configure(options)
  end
  
  # Accepted options are: :deny_user_agents and :deny_ip_address
  # Both accept a single or an array of String, Regexp or Proc objects
  # If a string is given, IP address will be matched by prefix (i.e. '127.0' will match '127.0.0.1' and '127.0.2.1')
  def configure(options = {})
    @user_agent_checks = [options[:deny_user_agent]].flatten.compact
    @ip_address_checks = [options[:deny_ip_address]].flatten.compact
  end
  
  def call(env)
    dup._call(env)
  end
  
  def _call(env)
    if access_denied?(env)
      deny_access
    else
      @app.call(env)
    end
  end
  
  def access_denied?(env)
    ip_denied?(env['REMOTE_ADDR']) || user_agent_denied?(env['HTTP_USER_AGENT'])
  end
    
  def ip_denied?(ip)
    ip && @ip_address_checks.any? { |check| match_ip?(check, ip) }  
  end
  
  def match_ip?(check, ip)
    case check
    when Regexp
      check =~ ip
    when String
      ip[0, check.size] == check
    when Proc
      check.call(ip)
    else
      false
    end
  end

  def user_agent_denied?(ua)
    ua ||= ''
    @user_agent_checks.any? { |check| match_user_agent?(check, ua) }  
  end
  
  def match_user_agent?(check, ua)
    case check
    when Regexp
      check =~ ua
    when String
      ua == check
    when Proc
      check.call(ua)
    else
      false
    end    
  end

  # Used for testing
  attr_reader :user_agent_checks
  attr_reader :ip_address_checks

  protected
  
  def deny_access
    [403, {"Content-Type" => "text/html"}, ["<h1>403 Forbidden</h1>"]]
  end
 
end
