class Staff::StatisticsController < Staff::ApplicationController

  before_filter :set_active_tab

  def set_active_tab
    @active_tab = "statistics"
  end

  def index
    @course_rank = current_center.course_rank
    @book_rank = current_center.book_rank
    @profile = params[:profile]

    @start_time = params[:start_time]
    if @start_time.blank?
      start_date = Time.now.beginning_of_month 
    else
      start_time_ary = @start_time.split('-')
      start_date = Time.mktime(start_time_ary[0], start_time_ary[1]).beginning_of_month
    end
    @end_time = params[:end_time]
    if @end_time.blank?
      end_date = Time.now.end_of_month
    else
      end_time_ary = @end_time.split('-')
      end_date = Time.mktime(end_time_ary[0], end_time_ary[1]).end_of_month
    end
    bills = current_center.bills.where(:created_at.gt => start_date).where(:created_at.lt => end_date)
    @stat = Bill.amount_stats(bills)
    @bills = auto_paginate(bills)
    @bills[:data] = @bills[:data].map do |e|
      e.bills_info
    end
  end

  def client_stats
    @stat = current_center.client_stats
    render json: retval_wrapper({stat: @stat}) and return
  end

  def course_stats
    @stat = current_center.course_stats(params[:duration].to_i, params[:start_date], params[:end_date])
    render json: retval_wrapper({stat: @stat}) and return
  end

  def book_stats
    @stat = current_center.book_stats(params[:duration].to_i, params[:start_date], params[:end_date])
    render json: retval_wrapper({stat: @stat}) and return
  end
end