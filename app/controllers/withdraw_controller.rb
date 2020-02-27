class WithdrawController < ApplicationController
    
    def create
        user = current_user
        request = user.get_total_sales - user.get_withdrawn_total - params[:amount].to_i
        if request >= 0 
            user.withdrawals.create(amount: params[:amount])
            if user.valid? && user.save
                redirect_back(fallback_location: earnings_manager_path(:option => "Earnings"))
            end
        else
            flash[:alert] = "Sorry your withdrawal amount is too high. Please make sure you have enough funds to process your request."
            redirect_back(fallback_location: earnings_manager_path(:option => "Earnings"))
        end

    end

end
