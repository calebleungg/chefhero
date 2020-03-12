class WithdrawController < ApplicationController
    
    # method for creating user withdrawal 
    def create
        user = current_user
        
        # validating enough funds to withdraw
        request = user.get_total_sales - user.get_withdrawn_total - params[:amount].to_i
        if request >= 0 
            user.withdrawals.create(amount: params[:amount])
            # creationg validation
            if user.valid? && user.save
                flash[:notice] = "Withdrawal successful."
                redirect_back(fallback_location: earnings_manager_path(:option => "Earnings"))
            end
        else
            flash[:alert] = "Sorry your withdrawal amount is too high. Please make sure you have enough funds to process your request."
            redirect_back(fallback_location: earnings_manager_path(:option => "Earnings"))
        end

    end

end
