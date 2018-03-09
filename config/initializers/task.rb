require 'rufus-scheduler'
scheduler = Rufus::Scheduler.new
 
scheduler.cron '0 12 * * *' do
  CourseParticipate.send_course_remind
  BookBorrow.send_book_remind
  print "ZZZZZZZZZZZZZZZZZZZZ"
  Rails.logger.info "YYYYYYYYYYYYYYYYY"
end

scheduler.every("1d") do

  CourseParticipate.all.each do |cp|
    if cp.refund_finished == true && !%w[CourseParticipate::SUCCESS, CourseParticipate::FAIL, CourseParticipate::CHANGE].include?(cp.refund_status)
      cp.refundquery
    end
    if cp.renew_status || (cp.pay_finished == true && cp.trade_state != "SUCCESS" && cp.price_pay > 0)
      cp.orderquery
    end
  end

  Deposit.all.each do |ele|
    if ele.renew_status || (ele.pay_finished == true && ele.trade_state != "SUCCESS" && ele.offline_paid == false)
      ele.orderquery
    end
  end
end
