class SignaturesController < ApplicationController
  include UserScoped

  def show
    redirect_to @user.signature
  end
end
