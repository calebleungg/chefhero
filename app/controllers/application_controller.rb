class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :set_variables

    # instancing notifications for current_user
    # queried by created_at ordered latest first
    def set_variables
        @notifications = current_user.notifications.order("created_at DESC") if user_signed_in?
    end

    # configurations to add attributes to devise user
    protected
    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :phone, :location, :account_type, :avatar, :stripe_id])
        devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :email, :phone, :location, :account_type, :avatar, :stripe_id])
    end


end
