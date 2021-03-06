require 'test_helper'

class RedcapTest < Minitest::Test
  REDCAP_HOST = "https://redcap.example.com"
  REDCAP_TOKEN = "abcd1234"

  def setup
    ENV['REDCAP_HOST'] = REDCAP_HOST
    ENV['REDCAP_TOKEN'] = REDCAP_TOKEN
    @redcap = Redcap.new
  end

  def teardown
    ENV['REDCAP_HOST'] = nil
    ENV['REDCAP_TOKEN'] = nil
  end

  def test_that_it_has_a_version_number
    refute_nil ::Redcap::VERSION
  end

  def test_that_it_has_a_configuration
    assert_instance_of Redcap::Configuration, @redcap.configuration
  end

  def test_that_host_initializes_from_env
    assert_equal @redcap.configuration.host, ENV['REDCAP_HOST']
  end

  def test_that_token_initializes_from_env
    assert_equal @redcap.configuration.token, ENV['REDCAP_TOKEN']
  end

  def test_that_format_defaults_to_json
    assert_equal @redcap.configuration.format, :json
  end

  def test_it_accepts_a_block
    Redcap.configure do |c|
      c.host = 'http://www.google.com'
      c.token = 1234
    end
    assert_equal Redcap.configuration.host, 'http://www.google.com'
    assert_equal Redcap.configuration.token, 1234
  end

  def test_it_accepts_a_hash
    redcap = Redcap.new host: 'http://www.yahoo.com', token: 5678
    assert_equal redcap.configuration.host, 'http://www.yahoo.com'
    assert_equal redcap.configuration.token, 5678
  end

  def test_it_has_a_logger
    assert_instance_of Logger, @redcap.logger
  end

  def test_log_is_off
    assert_equal @redcap.log?, false
  end

  def test_log_can_turn_on
    @redcap.log = true
    assert_equal @redcap.log?, true
  end
end
