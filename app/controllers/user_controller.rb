require "date_format"

class UserController < ApplicationController
    def index
    end

    def show
        @user = User.find(params[:id])
        @reviews = @user.reviews
        if @user.about == nil
            @about = ""
        else
            @about = @user.about
        end
        
        if @user.account_type == "chefhero"
            @dishes = @user.dishes.order("created_at DESC").limit(5)
            @total_orders = Order.total_for_chef(@user)
            @days_open = @user.availability.days_open if @user.availability
            begin
                @address_coordinates = Geocoder.search(@user.address.display_full).first.coordinates.reverse if @user.address
            rescue
                @address_coordinates = nil
            end
            @average_rating = @user.reviews.average(:rating)
        end
        
    
    end
    
    def upload_photo
        @user = current_user
        @user.avatar.attach(params[:user][:avatar])
        if @user.save
            redirect_to user_path(@user)
        end
    end

    def update_about
        @user = current_user
        @user.update(user_params)
        if @user.valid? && @user.save
            redirect_to user_path(@user)
        end
    end

    def details
    end

    def edit
        @user = current_user
    end

    def update
        @user = current_user
        @user.update!(user_params)

        if @user.valid? && @user.save
            flash[:notice] = "Saved successfully."
            redirect_to details_path
        else
            flash[:alert] = "Something went wrong when trying to save. Try again."
            render "edit"
        end
    end

    def manager
        @user = current_user
        @dishes = @user.dishes.order("created_at DESC")
        @availability = @user.availability
        @address = @user.address
        
        render layout: "dashboard"
    end

    private
    def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :phone, :location, :about, :avatar)
    end
end
