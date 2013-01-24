
### gem install 'sshkeyproof'

If you have a user's public key, you can verify they are who they say they are (ie. they hold the correspending private key):
    

### Client

The client takes their private key (defaults to ~/.ssh/id_rsa) and encrypts a random string as proof of work.

    request = Sshkeyproof::Client.new key_file: "./id_rsa"
    
    
### Server

The server takes the request string and verifies it

    s = Sshkeyproof::Server.new request
 
    s.fingerprint # => public key SHA1 fingerprint

    s.correct?(public_key)   # => true


