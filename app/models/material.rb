class Material

  include Mongoid::Document
  include Mongoid::Timestamps

  field :path, type: String
  field :type, type: String

end