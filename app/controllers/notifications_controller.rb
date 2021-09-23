class NotificationsController < ApplicationController
    before_action :authenticate_user!

    def index
        @notifications = current_user.reverse_notifications
        @notifications.where(checked: false).each do |notification|
            notification.update_attributes(checked: true)
        end        
    end
    
    def destroy
        @notifications = current_user.reverse_notifications.destroy_all
        redirect_to root_path
    end
end
