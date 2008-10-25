require 'queue_dumper'
require 'lock'
require 'yaml'
require 'queue_server_constants'

class QueueController < ApplicationController
  include Follotter::QueueServerConstants

  def next
    queue_next = nil
    Follotter::Lock.lock {
      queue_next = Follotter::QueueDumper.queue_next
      p queue_next.first['id']
      if queue_next.first['id'].to_s==END_ID.to_s
        Follotter::QueueDumper.build_queue
        queue_next = Follotter::QueueDumper.queue_next
      end
    }
    render :text=>queue_next.to_yaml, :layout=>false
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
