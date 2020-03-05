class NotificationController < ApplicationController

    def clear
        Notification.update_all(read: true)
        redirect_back(fallback_location: root_path)
    end

end
