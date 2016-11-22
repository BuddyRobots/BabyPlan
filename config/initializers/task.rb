require 'rufus-scheduler'
scheduler = Rufus::Scheduler.new
 
scheduler.every("1d") do
  # puts Time.now
  Center.all.each do |e|
    e.calculate_daily_stats
  end
end
