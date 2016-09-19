class Client::CentersController < Client::ApplicationController
  before_filter :require_sign_in, only: []

  def index
  end

  def show
  end
end
