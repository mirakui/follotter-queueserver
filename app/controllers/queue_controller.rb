require 'queue_dumper'
require 'lock'

class QueueController < ApplicationController
  def next
    queue_next = nil
    Follotter::Lock.lock {
      queue_next = Follotter::QueueDumper.queue_next
    }
    render :text=>queue_next, :layout=>false
  end
end
