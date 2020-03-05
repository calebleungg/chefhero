class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :set_variables

    def set_variables
        @notifications = current_user.notifications.where(read: false).order("created_at DESC") if user_signed_in?
    end

    protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :phone, :location, :account_type, :avatar, :stripe_id])
        devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :email, :phone, :location, :account_type, :avatar, :stripe_id])
    end


end
