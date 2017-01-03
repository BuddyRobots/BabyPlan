# encoding: utf-8
class Avatar

  extend CarrierWave::Mount
  mount_uploader :avatar, AvatarUploader

end
