class Vote


  include Mongoid::Document
  include Mongoid::Timestamps

  blongs_to :topic
end