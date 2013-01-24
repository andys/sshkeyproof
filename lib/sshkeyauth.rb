
require 'openssl'
require 'sshkey'

module Sshkeyproof
  class Client
    def initialize(params={})
      key_file = params[:key_file] || '~/.ssh/id_rsa'
      ssh_key  = params[:ssh_key] || File.read(key_file)
      openssl_key = params[:openssl_key] || OpenSSL::PKey::RSA.new(ssh_key)
      @privkey = openssl_key if openssl_key.private?
      @pubkey = @privkey && @privkey.public_key || openssl_key
    end
    
    def random
      @random ||= OpenSSL::Random.random_bytes(10).unpack('H*').first
    end
    
    def request
      ciphertext = @privkey.private_encrypt(random).unpack('H*').first
      "#{SSHKey.sha1_fingerprint(@pubkey.to_s)}|#{random.unpack('H*').first}|#{ciphertext}"
    end
    
  end
  
  class Server
    attr_reader :fingerprint
    def initialize(request_string)
      (@fingerprint,@random,@ciphertext) = request_string.to_s.split("|")
    end
    
    def correct?(key)
      openssl_key = String===key ? OpenSSL::PKey::RSA.new(key) : key
      @fingerprint && @random && @ciphertext && openssl_key.public_key.public_decrypt([@ciphertext].pack('H*')) == [@random].pack('H*') rescue nil
    end
  end
  
end
