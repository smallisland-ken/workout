class ApplicationController < ActionController::Base
  before_action :set_host

  def set_host
    Rails.application.routes.default_url_options[:host] = request.host_with_port
  end

  protect_from_forgery with: :null_session
  
  #言語切り替え
  before_action :set_locale

  #パスのパラメータを現在の言語I18n.localeに設定
  def set_locale 
    I18n.locale = params[:locale] || I18n.default_locale
  end
  
  #デフォルト値として現在の言語を指定
  #この記述をすることでviewのpassに毎回localeという記述をしなくてもよくなる。
  def default_url_options
     { :locale => I18n.locale }
  end
  
  # フラッシュメッセージがdefaultではalertとnoticeしかないので追加
  # 参考記事 https://note.com/asm_18/n/n22e76d73760b
  add_flash_types :success, :info, :warning, :danger, :notice

  before_action :configure_permitted_parameters, if: :devise_controller?

  # 投稿一覧へ遷移
  def after_sign_in_path_for(resource)
    root_path
  end

  # ログイン画面へ遷移
  def after_sign_out_path_for(resource)
    user_session_path
  end

  # view数を確認するための記述
  impressionist :actions => [:show, :index]

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname, :height, :weight, :gender, :introduction, :profile_image])
  end
end
