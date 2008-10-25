require 'queue_dumper'
require 'lock'
require 'yaml'
require 'queue_server_constants'

class QueueController < ApplicationController
  include Follotter::QueueServerConstants

  def next
    queue_next = nil
    Follotter::Lock.lock {
      queue_next = Follotter::QueueDumper.queue_next.to_yaml
      if queue_next.first['id']==END_ID
        Follotter::QueueDumper.build_queue
        queue_next = Follotter::QueueDumper.queue_next.to_yaml
      end
    }
    render :text=>queue_next, :layout=>false
  end

  def build
    result = nil
    Follotter::Lock.lock {
      num_rows = Follotter::QueueDumper.build_queue
      result = {'num_rows' => num_rows}.to_yaml
    }
    render :text=>result, :layout=>false
  end
end
