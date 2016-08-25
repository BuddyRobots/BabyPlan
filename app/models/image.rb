class Image

  include Mongoid::Document
  include Mongoid::Timestamps

  field :path, type: String

end