class Transfer

  include Mongoid::Document
  include Mongoid::Timestamps

  field :out_time, type: Time
  field :in_time, type: Time
  field status: type: Integer

  belongs_to :out_center, class_name: "Center", inverse_of: :out_transfers
  belongs_to :in_center, class_name: "Center", inverse_of: :in_transfers
  has_and_belongs_to_many, :books

end