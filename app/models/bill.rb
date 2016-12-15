class Bill

  include Mongoid::Document
  include Mongoid::Timestamps

  COURSE_PARTICIPATE = 1
  COURSE_REFUND = 2
  DEPOSIT_PAY = 4
  DEPOSIT_REFUND = 8
  LATEFEE_PAY = 16

  WECHAT = 1
  OFFLINE = 2

  field :amount, type: Float
  field :type, type: Integer
  field :channel, type: Integer
  field :finished, type: Boolean, default: true

  field :order_id, type: String
  field :wechat_transaction_id, type: String

  belongs_to :center
  belongs_to :user
  belongs_to :course_inst

  def self.create_course_participate_item(course_participate)
    if course_participate.price_pay <= 0
      return
    end
    Bill.create({
      center_id: course_participate.course_inst.center.id,
      user_id: course_participate.client.id,
      course_inst_id: course_participate.course_inst.id,
      amount: course_participate.price_pay,
      type: COURSE_PARTICIPATE,
      channel: WECHAT,
      order_id: course_participate.order_id,
      wechat_transaction_id: course_participate.wechat_transaction_id,
      finished: false
    })
  end

  def self.confirm_course_participate_item(course_participate)
    bill_item = Bill.where(order_id: course_participate.order_id, type: COURSE_PARTICIPATE).first
    if bill_item.present?
      bill_item.update_attribute(:finished, true)
    end
  end

  def self.create_course_refund_item(course_participate)
    if course_participate.price_pay <= 0
      return
    end
    Bill.create({
      center_id: course_participate.course_inst.center.id,
      user_id: course_participate.client.id,
      course_inst_id: course_participate.course_inst.id,
      amount: -course_participate.price_pay,
      type: COURSE_REFUND,
      channel: WECHAT,
      order_id: course_participate.order_id,
      wechat_transaction_id: course_participate.wechat_transaction_id,
      finished: false
    })
  end

  def self.confirm_course_refund_item(course_participate)
    bill_item = Bill.where(order_id: course_participate.order_id, type: COURSE_REFUND).first
    if bill_item.present?
      bill_item.update_attribute(:finished, true)
    end
  end

  def self.create_offline_deposit_pay_item(center, deposit)
    Bill.create({
      center_id: center.id,
      user_id: deposit.user.id,
      amount: deposit.amount,
      type: DEPOSIT_PAY,
      channel: OFFLINE
    })
  end

  def self.create_online_deposit_pay_item(deposit)
    Bill.create({
      user_id: deposit.user.id,
      amount: deposit.amount,
      type: DEPOSIT_PAY,
      channel: WECHAT,
      order_id: deposit.order_id,
      wechat_transaction_id: deposit.wechat_transaction_id,
      finished: false
    })
  end

  def self.confirm_online_deposit_pay_item(deposit)
    bill_item = Bill.where(order_id: deposit.order_id, type: DEPOSIT_PAY).first
    if bill_item.present?
      bill_item.update_attribute(:finished, true)
    end
  end

  def self.create_deposit_refund_item(center, deposit)
    Bill.create({
      center_id: center.id,
      user_id: deposit.user.id,
      amount: -deposit.amount,
      type: DEPOSIT_REFUND,
      channel: OFFLINE
    })
  end

  def self.create_latefee_pay_item(center, user, amount)
    Bill.create({
      center_id: center.id,
      user_id: user.id,
      amount: amount,
      type: LATEFEE_PAY,
      channel: OFFLINE
    })
  end

  def fund_type
    if self.type == LATEFEE_PAY
      return "滞纳金缴纳"
    end
    if self.type == DEPOSIT_REFUND
      return "押金退回"
    end
    if self.type == DEPOSIT_PAY
      return "押金缴纳"
    end
    if self.type = COURSE_REFUND
      return "课程退款"
    end
    if self.type == COURSE_PARTICIPATE
      return "课程报名"
    end
  end

  def fund_channel
    if self.channel == OFFLINE
      return "现金"
    end
    if self.channel == WECHAT
      return "微信"
    end
  end

  def amount_nums
    if self.amount >= 0
      return "+" + self.amount.to_s
    else
      return self.amount
    end
  end

  def amount_class
    if self.amount >= 0
      return "income_in"
    else
      return "income_out"
    end
  end

  def course_name
    self.course_inst.nil? ? "无" : self.course_inst.name
  end

  def bills_info
    {
      id: self.id.to_s,
      date: Time.at(self.created_at).strftime("%Y.%m.%d"),
      time: Time.at(self.created_at).strftime("%H:%M"),
      name: self.user.name,
      fund_type: self.fund_type,
      fund_channel: self.fund_channel,
      course_name: self.course_name,
      amount_nums: self.amount_nums,
      amount_class: self.amount_class
    }
  end

  def self.amount_stats(bills)
    total_amount = bills.sum("amount")
    # 两种方法都可以在mongoid中应用
    weixin_amount = bills.where(channel: WECHAT).map { |e| e.amount}.sum()
    offline_amount = bills.where(channel: OFFLINE).sum("amount")
    {
      total_amount: total_amount,
      weixin_amount: weixin_amount,
      offline_amount: offline_amount
    }
  end
end
