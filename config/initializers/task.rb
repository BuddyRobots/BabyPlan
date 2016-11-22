require 'rufus-scheduler'
scheduler = Rufus::Scheduler.new
 
scheduler.every("1d") do
  # puts Time.now
  Statistic.calculate_daily_stats
end
