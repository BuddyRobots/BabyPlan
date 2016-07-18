class User

  include Mongoid::Document
  include Mongoid::Timestamps

  field :email,    :type => String
  field :password, :type => String
  field :name,     :type => String
  field :region,   :type => Integer

end
