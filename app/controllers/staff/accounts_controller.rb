class Staff::AccountsController < Staff::ApplicationController
  before_filter :require_sign_in

  # show the index page
  def index

  end

  def update
    if @current_user.blank?
      redirect_to action: :signin_page and return
    end
    @current_user.name = params[:user_name]
    avatar = Avatar.new
    avatar.avatar = params[:photo_file]
    avatar.store_avatar!
    filepath = avatar.avatar.file.file
    m = Material.create(path: "/uploads/avatars/" + filepath.split('/')[-1])
    @current_user.avatar = m
    @current_user.save
    redirect_to action: :index and return
  end
 
end
