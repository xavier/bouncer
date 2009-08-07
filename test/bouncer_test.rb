
require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/bouncer.rb')

class App
  
  def call(env)
    [200, {"Content-Type" => "text/plain"}, "OK"]
  end
  
end

class BouncerTest < Test::Unit::TestCase

  EXAMPLE_CONFIGURATION = {
    :deny_ip_address => ['127.0.0.1', /^10\.\d+\.\d+\.\d+/, lambda { |ip| ip =~ /\.13$/ } ],
    :deny_user_agent => ["", "msnbot", /daodao/, lambda { |ua| ua.length == 3 } ],
  }
  
  def setup
    @app = App.new
    @bouncer = Bouncer.new(@app)
  end
  
  def test_default_options
    default_status_assertions
    assert_nothing_raised { @bouncer.call({}) }
  end
  
  def test_configure_with_no_options
    @bouncer.configure
    default_status_assertions
  end
  
  def test_configure
    @bouncer.configure(EXAMPLE_CONFIGURATION)
    assert_equal 3, @bouncer.ip_address_checks.size
    assert_equal 4, @bouncer.user_agent_checks.size
  end
  
  def test_match_ip
    assert @bouncer.match_ip?("127.0.0.1", "127.0.0.1")
    assert @bouncer.match_ip?("127.0", "127.0.0.1")
    assert @bouncer.match_ip?("127.0", "127.0.2.1")
    assert @bouncer.match_ip?(/^127/, "127.0.0.1")
    assert @bouncer.match_ip?(/^127\.0\.0.\d+/, "127.0.0.1")
    assert @bouncer.match_ip?(lambda { |ip| ip == '127.0.0.1' }, "127.0.0.1")
    assert !@bouncer.match_ip?("127.0.0.1", "127.0.0.2")
    assert !@bouncer.match_ip?("127.0", "127.1.0.0")
    assert !@bouncer.match_ip?(/10\.0/, "127.1.0.0")
    assert !@bouncer.match_ip?(lambda { |ip| false }, "127.0.0.1")    
  end
  
  def test_match_user_agent
    assert @bouncer.match_user_agent?("daodao larbin@unspecified.email", "daodao larbin@unspecified.email")
    assert !@bouncer.match_user_agent?("daodao", "daodao larbin@unspecified.email")
    assert @bouncer.match_user_agent?(/daodao/, "daodao larbin@unspecified.email")
    assert @bouncer.match_user_agent?(/larbin/, "daodao larbin@unspecified.email")
  end
  
  def test_ip_denied
    @bouncer.configure(EXAMPLE_CONFIGURATION)
    assert @bouncer.ip_denied?('127.0.0.1')
    assert @bouncer.ip_denied?('10.2.3.4')
    assert @bouncer.ip_denied?('10.20.30.40')
    assert !@bouncer.ip_denied?('127.0.0.2')
    assert !@bouncer.ip_denied?(nil)
    assert !@bouncer.ip_denied?('')
  end

  def test_user_agent_denied
    @bouncer.configure(EXAMPLE_CONFIGURATION)
    assert @bouncer.user_agent_denied?('')
    assert @bouncer.user_agent_denied?(nil)
    assert @bouncer.user_agent_denied?('msnbot')
    assert @bouncer.user_agent_denied?('daodao larbin@unspecified.email')
    assert @bouncer.user_agent_denied?('daodao')
    assert @bouncer.user_agent_denied?('123')
    assert !@bouncer.user_agent_denied?('GoogleBot')
    assert !@bouncer.user_agent_denied?('Mozilla/5.0 (Windows; U; Windows NT 5.1; en) AppleWebKit/526.9 (KHTML, like Gecko) Version/4.0dp1 Safari/526.8')
  end
  
  def test_allowed_request
    @bouncer.configure(EXAMPLE_CONFIGURATION)
    @env = {
      'REMOTE_ADDR' => '1.2.3.4',
      'PATH_INFO'   => '/path',
      'HTTP_USER_AGENT'  => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en) AppleWebKit/526.9 (KHTML, like Gecko) Version/4.0dp1 Safari/526.8'
    }
    assert_equal 200, @bouncer.call(@env).first
  end
  
  def test_denied_request
      @bouncer.configure(EXAMPLE_CONFIGURATION)
      @env = {
        'REMOTE_ADDR' => '1.2.3.4',
        'PATH_INFO'   => '/path',
        'HTTP_USER_AGENT'  => 'msnbot'
      }
      assert_equal 403, @bouncer.call(@env).first
  end
  
  def test_configuration_with_single_items
    @bouncer.configure(:deny_ip_address => '127.0.0.1', :deny_user_agent => /msnbot/)
    assert @bouncer.ip_denied?('127.0.0.1')
    assert !@bouncer.ip_denied?('10.0.0.1')
    assert @bouncer.user_agent_denied?('msnbot')
    assert !@bouncer.user_agent_denied?('Safari')
  end
  
  protected
  
  def default_status_assertions
    assert @bouncer.ip_address_checks.empty?
    assert @bouncer.user_agent_checks.empty?
  end
  
end