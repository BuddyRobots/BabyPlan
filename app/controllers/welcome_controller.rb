class WelcomeController < ApplicationController
  def index
  end

  def test
  end

  def test_image_uploader
  end

  def weixin
    case params[:xml]["MsgType"]
    when "text"
      if params[:xml]["Content"] == "我是工作人员"
        data = {
          "ToUserName" => params[:xml]["FromUserName"],
          "FromUserName" => params[:xml]["ToUserName"],
          "CreateTime" => Time.now.to_i,
          "MsgType" => "text",
          # "Content" => "<a href='#{Weixin.generate_authorize_link(Rails.application.config.server_host + "/coach/students")}/'>工作人员入口</a>"
          "Content" => "<a href='http://www,baidu.com'>工作人员入口</a>"
        }
        render :xml => data.to_xml(root: "xml") and return
      else
        render text: "" and return
      end
    when "event"
=begin
      if params[:xml]["Event"] == "CLICK" && ["MSWK", "ZCKD", "JYZT"].include?(params[:xml]["EventKey"])
        news = WeixinNews.where(active: true, type: params[:xml]["EventKey"]).desc(:created_at).limit(3)
        data = {
          "ToUserName" => params[:xml]["FromUserName"],
          "FromUserName" => params[:xml]["ToUserName"],
          "CreateTime" => Time.now.to_i,
          "MsgType" => "news",
          "ArticleCount" => news.length,
          "Articles" => [ ]
        }
        news.each_with_index do |n, i|
          data["Articles"] << {
            "item_#{i}" => {
              "Title" => n.title,
              "Description" => n.desc,
              "PicUrl" => Rails.application.config.server_host + n.pic_url,
              "Url" => n.url
            }
          }
        end
        retval = data.to_xml(root: "xml").gsub(/item-\d/, "item").gsub("<Article>", "").gsub("</Article>", "")
        render :xml => retval and return
      end
=end
      if params[:xml]["Event"] == "subscribe"
        data = {
          "ToUserName" => params[:xml]["FromUserName"],
          "FromUserName" => params[:xml]["ToUserName"],
          "CreateTime" => Time.now.to_i,
          "MsgType" => "text",
          "Content" => "欢迎关注北京市社区儿童中心微信公众号"
        }
        render :xml => data.to_xml(root: "xml") and return
      else
        render text: "" and return
      end
    end
  end
end
