require 'rubygems'
require 'bundler'
Bundler.require
require 'faye'

require File.expand_path('../config/initializers/faye_token.rb', __FILE__)

class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      if message['ext']['auth_token'] != FAYE_TOKEN
        message['error'] = 'Invalid authentication token'
      end
    end
    callback.call(message)
  end

  # IMPORTANT: clear out the auth token so it is not leaked to the client
  def outgoing(message, callback)
    if message['ext'] && message['ext']['auth_token']
      message['ext'] = {} 
    end
    callback.call(message)
  end
end


bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
bayeux.add_extension(ServerAuth.new)
# bayeux.add_websocket_extension(PermessageDeflate)
run bayeux

# https://enigmatic-beyond-5945.herokuapp.com/faye
# https://warm-lake-9722.herokuapp.com/faye
# rackup faye.ru -s thin -E production

#