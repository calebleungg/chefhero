class Address < ApplicationRecord
    belongs_to :user

    def display_full
        return "#{street} #{suburb}, #{city} #{state} #{postcode}, #{country}"
    end
end
