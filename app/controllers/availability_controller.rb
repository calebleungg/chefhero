class AvailabilityController < ApplicationController

    def update
        user = current_user
        user.availability.update(
            monday: params[:availability][:monday],
            tuesday: params[:availability][:tuesday],
            wednesday: params[:availability][:wednesday],
            thursday: params[:availability][:thursday],
            friday: params[:availability][:friday],
            saturday: params[:availability][:saturday],
            sunday: params[:availability][:sunday],
        )
        if user.valid? && user.save
            redirect_to manager_path(:option => "Manager")
        end
    end



end
