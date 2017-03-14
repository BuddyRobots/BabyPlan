class Course

  include Mongoid::Document
  include Mongoid::Timestamps

  field :code, type: String, default: ""
  field :name, type: String
  field :length, type: Integer
  field :address, type: String
  field :capacity, type: Integer
  field :time, type: String
  field :desc, type: String
  field :target, type: String
  field :price, type: Integer
  field :price_pay, type: Integer
  field :speaker, type: String
  field :available, type: Boolean
  field :school, type: String
  field :min_age, type: Integer
  field :max_age, type: Integer
  

  has_one :photo, class_name: "Material", inverse_of: :course_photo
  has_many :course_insts
  has_many :reviews
  has_many :course_participates

  has_many :staff_logs

  scope :is_available, ->{ where(available: true) }


  def self.create_course(course_info)
    if Course.where(code: course_info[:code]).first.present?
      return ErrCode::COURSE_CODE_EXIST
    end
    course = Course.create(
      name: course_info[:name],
      length: course_info[:length].to_i,
      desc: course_info[:desc],
      price: course_info[:price],
      price_pay: course_info[:price_pay],
      speaker: course_info[:speaker],
      code: course_info[:code],
      available: course_info[:available]
    )
    { course_id: course.id.to_s }
  end

  def course_info
    {
      id: self.id.to_s,
      name: self.name,
      code: self.code,
      speaker: self.speaker,
      price: self.price,
      available: self.available
    }
  end

  def update_info(course_info)
    ci =  Course.where(code: course_info[:code]).first
    if ci.present? && ci.id != self.id
      return ErrCode::COURSE_CODE_EXIST
    end
    self.update_attributes(
      {
        name: course_info["name"],
        price: course_info["price"],
        price_pay: course_info["price_pay"],
        desc: course_info["desc"],
        code: course_info["code"],
        length: course_info["length"],
        speaker: course_info["speaker"]
      }
    )
    nil
  end

  def set_available(available)
    self.update_attribute(:available, available == true)
    nil
  end

  def self.course_stats(duration, start_date, end_date)
    if duration == -1
      start_time_ary = start_date.split('-').map { |e| e.to_i }
      start_time = Time.mktime(start_time_ary[0], start_time_ary[1], start_time_ary[2]).to_i
      end_time_ary = end_date.split('-').map { |e| e.to_i }
      end_time = Time.mktime(end_time_ary[0], end_time_ary[1], end_time_ary[2]).to_i
      duration = [0, end_time - start_time].max
    else
      start_time = Time.now.to_i - duration
      end_time = Time.now.to_i
    end
    duration_days = duration / 1.days.to_i
    if duration_days < 15
      time_unit = "天数"
      day = 1
    elsif duration_days < 120
      time_unit = "周数"
      day = 7
    else
      time_unit = "月数"
      day = 30
    end
    signup_num = Statistic.where(type: Statistic::COURSE_SIGNUP_NUM).
                                 where(:stat_date.gt => start_time).
                                 where(:stat_date.lt => end_time).
                                 desc(:stat_date).map { |e| e.value }
    signup_num = signup_num.each_slice(day).map { |a| a }
    signup_num = signup_num.map { |e| e.sum } .reverse
    allowance = Statistic.where(type: Statistic::ALLOWANCE).
                                where(:stat_date.gt => start_time).
                                where(:stat_date.lt => end_time).
                                desc(:stat_date).map { |e| e.value }
    allowance = allowance.each_slice(day).map { |a| a }
    allowance = allowance.map { |e| e.sum } .reverse
    income = Statistic.where(type: Statistic::INCOME).
                             where(:stat_date.gt => start_time).
                             where(:stat_date.lt => end_time).
                             desc(:stat_date).map { |e| e.value }
    income = income.each_slice(day).map { |a| a }
    income = income.map { |e| e.sum } .reverse

    max_num = 5
    income_center_hash = { }
    Center.all.each do |c|
      allowance = c.statistics.where(type: Statistic::ALLOWANCE).
                               where(:stat_date.gt => start_time).
                               where(:stat_date.lt => end_time).
                               desc(:stat_date).map { |e| e.value }
      income = c.statistics.where(type: Statistic::INCOME).
                            where(:stat_date.gt => start_time).
                            where(:stat_date.lt => end_time).
                            desc(:stat_date).map { |e| e.value }
      income_center_hash[c.name] = allowance.sum + income.sum
    end
    income_center = income_center_hash.to_a
    income_center = income_center.sort { |x, y| -x[1] <=> -y[1] }
    if income_center.length > max_num
      ele = ["其他", income_center[max_num - 1..-1].map { |e| e[1] } .sum]
      income_center = income_center[0..max_num - 2] + [ele]
    end
    {
      signup_time_unit: time_unit,
      signup_num: signup_num,
      total_signup: signup_num.sum,
      total_income: income.sum,
      total_allowance: allowance.sum,
      income_time_unit: time_unit,
      allowance: allowance,
      income:income,
      total_money: allowance.sum + income.sum,
      income_center: income_center
    }
  end

  def self.course_rank(max_num = 5)
    courses = Course.all.map do |e|
      reviews = e.reviews
      score = reviews.map { |r| r.score || 0 } .sum * 1.0
      {
        id: e.id.to_s,
        name: e.name,
        cp_num: e.course_participates.where(trade_state: "SUCCESS").length,
        review_score: (reviews.blank? ? 0 : score / reviews.length).round(1)
      }
    end
    {
      review_rank: courses.sort { |x, y| -x[:review_score] <=> -y[:review_score] } [0...[max_num, courses.length - 1].min],
      cp_rank: courses.sort { |x, y| -x[:cp_num] <=> -y[:cp_num] } [0...[max_num, courses.length - 1].min],
    }
  end
end