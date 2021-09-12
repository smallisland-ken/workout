class NotificationsController < ApplicationController
    def index
        @notifications = current_user.reverse_notifications
        @notifications.where(checked: false).each do |notification|
            notification.update_attributes(checked: true)
        end        
    end
    
    def destroy_all
        @notifications = current_user.reverse_notifications.destroy_all
        redirect_to root_path
    end
end


