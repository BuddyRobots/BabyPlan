class CourseOrderExpiredWorker
  include Sidekiq::Worker

  def perform(cp_id)
  	cp = CourseParticipate.where(id: cp_id).first
    if cp.is_expired
      cp.closeorder_interface
    end
  end
end
