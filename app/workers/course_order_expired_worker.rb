class CourseOrderExpiredWorker
  include Sidekiq::Worker

  def perform(cp)
    if cp.is_expired
      cp.closeorder_interface
    end
  end
end
