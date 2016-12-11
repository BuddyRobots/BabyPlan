require 'rufus-scheduler'
scheduler = Rufus::Scheduler.new
 
scheduler.every("1d") do
  # puts Time.now
  Statistic.calculate_daily_stats
end

scheduler.every("1d") do
  CourseParticipate.all.each do |cp|
    if cp.refund_finished == true && !%w[CourseParticipate::SUCCESS, CourseParticipate::FAIL, CourseParticipate::CHANGE].include?(cp.refund_status)
      cp.refundquery
    end
  end
end
