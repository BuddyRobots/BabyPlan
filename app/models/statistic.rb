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
  ON_SHELF = 64             # number of books on the shelf

  field :type, type: Integer
  field :value, type: Float
  field :stat_date, type: Integer

  belongs_to :center

end