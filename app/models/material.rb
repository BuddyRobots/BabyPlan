class Material

  include Mongoid::Document
  include Mongoid::Timestamps

  COURSE = 1
  COVER = 2
  BACK = 4

  field :material_type, type: Integer
  field :path, type: String
end