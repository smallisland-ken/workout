class ApplicationController < ActionController::Base
  before_action :set_host

  def set_host
    Rails.application.routes.default_url_options[:host] = request.host_with_port
  end

  protect_from_forgery with: :null_session

  # フラッシュメッセージがdefaultではalertとnoticeしかないので追加
  # 参考記事 https://note.com/asm_18/n/n22e76d73760b
  add_flash_types :success, :info, :warning, :danger, :notice

  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    root_path
  end
  # 投稿一覧へ遷移

  def after_sign_out_path_for(resource)
    user_session_path
  end
  # ログイン画面へ遷移

  impressionist :actions => [:show, :index]
  # view数を確認するための記述

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname, :height, :weight, :gender, :introduction, :profile_image])
  end
end
