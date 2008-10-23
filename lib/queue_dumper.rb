require 'rubygems'
require 'pit'
require 'mysql'
require 'queue_server_constants'
require 'thread'
require 'lock'

module Follotter
  class QueueDumper
    include QueueServerConstants
    include Lock

    DEQUEUE_SIZE = 10
    
    def self.build_queue
      open(QUEUE_PATH, 'w') do |f|

        conf = Pit.get('folloter_mysql', :require=>{
          'username' => 'username',
          'password' => 'password',
          'database' => 'database',
          'host'=> 'host'
        })
        db = Mysql.new conf['host'], conf['username'], conf['password'], conf['database']

        q = "SELECT id,screen_name"+
            " FROM users"+
            " WHERE language='ja'"+
            " ORDER BY crawled_at ASC, followers_count DESC"

        res = db.query(q)
        res.each do |row|
          f.puts "#{row[0]} #{row[1]}"
        end

        db.close
      end
    end

    def self.queue(param={})
      index = param[:index] || 0
      size = param[:size] || DEQUEUE_SIZE

      res = nil

      queue_size = `/usr/bin/wc -l #{QUEUE_PATH}`.split(/\s+/).first.to_i

      cmd = "/usr/bin/tail -#{queue_size-index} #{QUEUE_PATH} | /usr/bin/head -#{size}"
      p cmd
      res = `#{cmd}`

      res
    end

    def self.seek
      s = nil
      if File.exist? SEEK_PATH
        open(SEEK_PATH, 'r') do|f|
          s = f.read.to_i
        end 
      else
        s = 0
      end
      s
    end

    def self.queue_next()
      s = self::seek_next(1)
      self::queue(:index=>s*DEQUEUE_SIZE, :size=>DEQUEUE_SIZE)
    end

    protected
    def self.seek_next(plus=1)
      s = nil
      if File.exist? SEEK_PATH
        open(SEEK_PATH, 'r') do|f|
          s = f.read.to_i
        end 
      else
        s = 0
      end
      open(SEEK_PATH, 'w') do |f|
        f.write(s+plus)
      end
      s
    end
  end
end

__END__

include Follotter

Lock.lock {
  puts '---a'
  p Follotter::QueueDumper.queue_next
  puts '---b'
  p Follotter::QueueDumper.queue_next
}

