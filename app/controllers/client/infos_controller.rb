class Client::InfosController < Client::ApplicationController
  before_filter :require_sign_in, only: []

  # show the index page
  def index
  end
end
