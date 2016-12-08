class Statistic

  include Mongoid::Document
  include Mongoid::Timestamps

  # all the statistics are within one day
  # types of statistics
  CLIENT_NUM = 1            # number of clients
  COURSE_SIGNUP_NUM = 2     # number of signups
  INCOME = 4                # amount of income
  ALLOWANCE = 8             # amount of allowance
  BORROW_NUM = 16           # number of borrow actions
  STOCK = 32                # number of books
  OFF_SHELF = 64            # number of books off the shelf

  field :type, type: Integer
  field :value, type: Float
  field :stat_date, type: Integer

  belongs_to :center

  def self.duration_for_select
    hash = { "快捷选择" => -1, "最近一个月" => 1.months.to_i, "最近三个月" => 3.months.to_i, "最近半年" => 6.months.to_i, "最近一年" => 12.months.to_i }
    hash 
  end

  def self.calculate_daily_stats
    # calculate global statistics
    date = Date.today - 1.days
    stat_date = Time.mktime(date.year, date.month, date.day).to_i
    # client number
    if Statistic.where(type: Statistic::CLIENT_NUM, stat_date: stat_date).blank?
      Statistic.create(type: Statistic::CLIENT_NUM, stat_date: stat_date, value: User.client.count)
    end

    # calculate statistics for each center
    Center.all.each do |e|
      e.calculate_daily_stats
    end
  end
end