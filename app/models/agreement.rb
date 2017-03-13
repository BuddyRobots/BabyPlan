class Agreement

  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :content, type: String

  def update_agreement(agreement_info)
    html = Nokogiri::HTML(agreement_info[:content])
    info = {
      title: agreement_info[:title],
      content: agreement_info[:content]
    }
    self.update_attributes(info)
    {agreement_id: self.id.to_s}
  end
end