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
      num_rows = 0
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
            " ORDER BY crawled_at ASC, followers_count DESC"+
            " LIMIT #{QUEUE_LIMIT}"

        res = db.query(q)
        num_rows = res.num_rows
        res.each do |row|
          f.puts "#{row[0]} #{row[1]}"
        end

        f.puts "#{END_ID} #{END_SCREEN_NAME}"
        File.delete SEEK_PATH

        db.close
      end
      num_rows
    end

    def self.queue(param={})
      index = param[:index] || 0
      size = param[:size] || DEQUEUE_SIZE

      res = nil
      
      unless File.exist?(QUEUE_PATH)
        self.build_queue 
        seek
      end

      queue_size = `/usr/bin/wc -l #{QUEUE_PATH}`.split(/\s+/).first.to_i
      if queue_size>=index
        cmd = "/usr/bin/tail -#{queue_size-index} #{QUEUE_PATH} | /usr/bin/head -#{size}"
        p cmd

        res = `#{cmd}`
        #res = "1 hoge\n2 moge"
        users = []
        res.split(/\n/).each do |line|
          col=line.split(/\s/)
          users << {'id'=>col[0], 'screen_name'=>col[1]}
        end

        users
      else
        [{'id'=>END_ID, 'screen_name'=>END_SCREEN_NAME}]
      end
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
      s = self::seek()
      q = self::queue(:index=>s*DEQUEUE_SIZE, :size=>DEQUEUE_SIZE)
      self::seek_next(1) unless q.empty?
      q
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

conf = Pit.get('folloter_mysql', :require=>{
  'username' => 'username',
  'password' => 'password',
  'database' => 'database',
  'host'=> 'host'
})
db = Mysql.new conf['host'], conf['username'], conf['password'], conf['database']

q = "SELECT id,screen_name,crawled_at"+
    " FROM users"+
    " WHERE language='ja'"+
    " ORDER BY crawled_at ASC, followers_count DESC"+
    " LIMIT 20"

res = db.query(q)
num_rows = res.num_rows
res.each do |row|
  p row
end
