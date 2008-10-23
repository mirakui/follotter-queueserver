require 'rubygems'
require 'queue_server_constants'

module Follotter
  module Lock
    include QueueServerConstants

    def self.lock
      lock = File.open(LOCK_PATH, 'w')
      lock.flock(File::LOCK_EX)

      yield
      
      lock.flock(File::LOCK_UN)
      lock.close
    end
  end
end
