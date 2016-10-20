class WelcomeController < ApplicationController
  def index
  end

  def test
  end

  def test_image_uploader
  end

  def weixin
  	doc = Nokogiri::XML(request.body.read)
  	hash = Hash.from_xml(doc.to_s)["xml"]
    case hash["MsgType"]
    when "text"
      if hash["Content"] == "我是工作人员"
        data = {
          "ToUserName" => hash["FromUserName"],
          "FromUserName" => hash["ToUserName"],
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
      if hash["Event"] == "CLICK" && ["MSWK", "ZCKD", "JYZT"].include?(hash["EventKey"])
        news = WeixinNews.where(active: true, type: hash["EventKey"]).desc(:created_at).limit(3)
        data = {
          "ToUserName" => hash["FromUserName"],
          "FromUserName" => hash["ToUserName"],
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
      if hash["Event"] == "subscribe"
        data = {
          "ToUserName" => hash["FromUserName"],
          "FromUserName" => hash["ToUserName"],
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
