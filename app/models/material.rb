class Material

  include Mongoid::Document
  include Mongoid::Timestamps

  field :path, type: String
  field :type, type: String

  belongs_to :cover_book, class_name: "Book", inverse_of: :cover
  belongs_to :back_book, class_name: "Book", inverse_of: :back
  belongs_to :center_photo, class_name: "Center", inverse_of: :photo

end