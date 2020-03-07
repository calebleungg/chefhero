class NotificationController < ApplicationController

    # method for changing all outstanding notifications to read = true
    def clear
        current_user.notifications.destroy_all
        redirect_back(fallback_location: root_path)
    end

end
