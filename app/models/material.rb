class Material

  include Mongoid::Document
  include Mongoid::Timestamps

  COURSE = 1
  COVER = 2
  BACK = 4

  field :material_type, type: Integer
  field :path, type: String

  #relationships specific for book
  belongs_to :cover_book, class_name:"Book", inverse_of: :cover
  belongs_to :back_book, class_name:"Book", inverse_of: :back

  #relationships specific for course
  belongs_to :course
end