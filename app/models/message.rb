class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  WECHAT = 1

  field :unread, type: Boolean, default: true
  field :content, type: String

  field :message_type, type: Integer
  field :errmsg, type: String
  field :errcode, type: Integer

  belongs_to :course_inst
  belongs_to :client, class_name: "User", inverse_of: :messages

  def self.create_refund_reject_message(course_participate)
    content = "课程《" + course_participate.course_inst.course.name + "》退款申请被工作人员拒绝，拒绝理由：" + course_participate.refund_feedback
    course_participate.client.messages.create(content: content)
  end

  def self.course_notice_create(type, content, errcode, errmsg, course_id)
    course_inst = CourseInst.where(id: course_id).first
    message = course_inst.messages.create(
      message_type: type,
      content: content,
      errcode: errcode,
      errmsg: errmsg
      )
  end
end
