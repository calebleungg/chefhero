class AddressController < ApplicationController

    # method for creating an address for user
    def update
        user = current_user
        user.address.update(
            street: params[:address][:street],
            suburb: params[:address][:suburb],
            city: params[:address][:city],
            state: params[:address][:state],
            postcode: params[:address][:postcode],
            country: params[:address][:country],
        )
        if user.valid? && user.save
            redirect_to manager_path(:option => "Manager")
        end
    end

end
