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
    if cp.pay_finished == true && cp.trade_state != "SUCCESS" && cp.price_pay > 0
      cp.orderquery
    end
  end

  Deposit.all.each do |ele|
    if ele.pay_finished == true && ele.trade_state != "SUCCESS" && ele.offline_paid == false
      ele.orderquery
    end
  end
end
