class ApplicationController < ActionController::Base
      before_action :configure_permitted_parameters, if: :devise_controller?
      
      impressionist :actions=>[:show,:index]
      # view数を確認するための記述

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname,:height,:weight,:gender,:introduction])
  end

end
