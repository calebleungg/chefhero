class NotificationController < ApplicationController

    # method for changing all outstanding notifications to read = true
    def clear
        Notification.update_all(read: true)
        redirect_back(fallback_location: root_path)
    end

end
