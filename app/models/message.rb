class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :unread, type: Boolean, default: true
  field :content, type: String

  belongs_to :client, class_name: "User", inverse_if: :messages

  def self.create_refund_reject_message(course_participate)
    content = "课程《" + course_participate.course_inst.course.name + "》退款申请被工作人员拒绝，拒绝理由：" + course_participate.refund_feedback
    course_participate.client.messages.create(content: content)
  end
end