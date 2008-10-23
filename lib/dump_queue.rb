require 'rubygems'
require 'pit'
require 'mysql'
require 'queue_server_constances'

module Follotter
  class QueueDumper
    include QueueServerConstances
    
    def self.dump
      lock = File.open(LOCK_PATH, 'w')
      lock.flock(File::LOCK_EX)
      open(OUT_PATH, 'w') do |f|

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
      lock.flock(File::LOCK_UN)
      lock.close
    end

    def queue(range)
    end
  end
end

__END__

Follotter::QueueDumper.dump

