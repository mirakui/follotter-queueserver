module Follotter
  module QueueServerConstants
    PATH_BASE = File.dirname(__FILE__)+'/..'
    QUEUE_PATH = PATH_BASE+'/queue/queue'
    LOCK_PATH = PATH_BASE+'/queue/lock'
    SEEK_PATH = PATH_BASE+'/queue/seek'
    END_ID = '-1'
    END_SCREEN_NAME = '=END'
  end
end
