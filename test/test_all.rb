require "#{File.dirname(__FILE__)}/../lib/sshkeyproof"
require 'test/unit'

 class TestSshkeyproof < Test::Unit::TestCase
  def setup
    @ssh_key = SSHKey.generate(type:"RSA", bits:1024, comment:"foo@bar.com")
    @client = Sshkeyproof::Client.new ssh_key: @ssh_key.private_key
    @request = @client.request
  end

  def test_success
    server = Sshkeyproof::Server.new @request
    assert_equal true, server.correct?(@ssh_key.public_key)
  end
  
  def test_bad_ciphertext
    badrequest = @request.dup
    
    #fiddle the cipher text
    badrequest[-3] = '0'
    badrequest[-2] = '0'
    badrequest[-1] = '0'
    
    server = Sshkeyproof::Server.new badrequest
    assert_equal nil, server.correct?(@ssh_key.public_key)
  end

  def test_wrong_key
    ssh_key2 = SSHKey.generate(type:"RSA", bits:1024, comment:"foo@bar.com")
    client2 = Sshkeyproof::Client.new ssh_key: ssh_key2.private_key
    request2 = client2.request

    server = Sshkeyproof::Server.new request2
    assert_equal nil, server.correct?(@ssh_key.public_key)
  end
end
