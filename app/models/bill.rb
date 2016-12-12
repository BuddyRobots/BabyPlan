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
end
