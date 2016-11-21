require 'rufus-scheduler'
scheduler = Rufus::Scheduler.new
 
scheduler.every("1m") do
   puts "AAAAAAAAAAAAAAAAAAAAA"
   puts Time.now
end
scheduler.join