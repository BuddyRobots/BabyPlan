class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  before_filter :init

  attr_reader :current_user
  attr_reader :center_name

  def retval_wrapper(value)
    retval = ErrCode.ret_false(value)
    retval.nil? ? { success: true }.merge(value || {}) : retval
  end

  def init
    @remote_ip = request.remote_ip
    @code = params[:code]
    refresh_session(params[:auth_key] || cookies[:auth_key])
  end

  def refresh_session(auth_key)
    @current_user = auth_key.blank? ? nil : User.find_by_auth_key(auth_key)
    if !current_user.nil?
      # If current user is not empty, set cookie
      cookies[:auth_key] = {
        :value => auth_key,
        :expires => 24.months.from_now,
        :domain => :all
      }
      return true
    else
      # If current user is empty, delete cookie
      cookies.delete(:auth_key, :domain => :all)
      return false
    end
  end

  def page
    params[:page].to_i == 0 ? 1 : params[:page].to_i
  end

  def per_page
    params[:per_page].to_i == 0 ? 10 : params[:per_page].to_i
  end

  # kaminari API
  def auto_paginate(value, count = nil)
    retval = {}
    retval[:current_page] = page
    retval[:per_page] = per_page
    retval[:previous_page] = (page - 1 > 0 ? page - 1 : 1)

    # 当没有block或者传入的是一个mongoid集合对象时就自动分页
    # TODO : 更优的判断是否mongoid对象?
    # instance_of?(Mongoid::Criteria) .by lcm
    # if block_given? 
    # if value.methods.include? :page
    if value.instance_of?(Mongoid::Criteria)
      count ||= value.count
      value = value.page(retval[:current_page]).per(retval[:per_page])
    elsif value.is_a?(Array) && value.count > per_page
      count ||= value.count
      value = value.slice((page - 1) * per_page, per_page)
    end
      
    if block_given?
      retval[:data] = yield(value) 
    else
      retval[:data] = value
    end
    retval[:total_page] = ( (count || value.count )/ per_page.to_f ).ceil
    retval[:total_page] = retval[:total_page] == 0 ? 1 : retval[:total_page]
    retval[:total_number] = count || value.count
    retval[:next_page] = (page+1 <= retval[:total_page] ? page+1: retval[:total_page])
    retval
  end

  # def auto_paginate(value, count = nil)
  #   retval = {}
  #   retval[:current_page] = page
  #   retval[:per_page] = per_page
  #   retval[:previous_page] = (page - 1 > 0 ? page - 1 : 1)

  #   if value.instance_of?(Mongoid::Criteria)
  #     count ||= value.count
  #     value = value.page(retval[:current_page]).per(retval[:per_page])
  #   elsif value.is_a?(Array) && value.count > per_page
  #     count ||= value.count
  #     value = value.slice((page - 1) * per_page, per_page)
  #   end
  #   if block_given?
  #     retval[:data] = yield(value)
  #   else
  #     retval[:data] = value
  #   end
  #   retval[:total_page] = ( (count || value.count) / per_page.to_f ).ceil
  #   retval[:total_page] = retval[:total_page] == 0 ? 1 : retval[:total_page]
  #   retval[:total_number] = count || value.count
  #   retval[:next_page] = (page + 1 <= retval[:total_page] ? page + 1 : retval[:total_page])
  #   retval
  # end

  def signature
    @jsapi_ticket = Weixin.get_jsapi_ticket
    @noncestr = rand(36**10).to_s 36
    @timestamp = Time.now.to_i
    @url = CGI::unescape(params[:url])
    string = "jsapi_ticket=#{@jsapi_ticket}&noncestr=#{@noncestr}&timestamp=#{@timestamp}&url=#{@url}"
    @signature = Digest::SHA1.hexdigest(string)
    retval = {
      success: true,
      data: {
        signature: @signature,
        noncestr: @noncestr,
        timestamp: @timestamp,
        appid: Weixin::APPID,
        string: string,
        jsapi_ticket: @jsapi_ticket
      }
    }
    render json: retval and return
  end

end
