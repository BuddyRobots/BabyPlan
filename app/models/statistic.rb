require 'zip'
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
end