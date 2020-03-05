class Address < ApplicationRecord
    belongs_to :user

    # method to print full address
    def display_full
        return "#{street} #{suburb}, #{city} #{state} #{postcode}, #{country}"
    end

    
end
