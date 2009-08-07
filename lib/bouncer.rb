
class Bouncer

  #
  #
  #
  
  def initialize(app, options = {})
    @app = app
    configure(options)
  end
  
  #
  #
  #
  #
  def configure(options = {})
    @user_agent_checks = [options[:deny_user_agent]].flatten.compact
    @ip_address_checks = [options[:deny_ip_address]].flatten.compact
  end
  
  attr_reader :user_agent_checks
  attr_reader :ip_address_checks
  
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

  protected
  
  def deny_access
    [403, {"Content-Type" => "text/html"}, ["<h1>403 Forbidden</h1>"]]
  end
 
end
