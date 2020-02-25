class Availability < ApplicationRecord
    belongs_to :user

    def days_open
        days = {}
        days[:monday] = self.monday if self.monday != nil && self.monday != ""
        days[:tuesday] = self.tuesday if self.tuesday != nil && self.tuesday != ""
        days[:wednesday] = self.wednesday if self.wednesday != nil && self.wednesday != ""
        days[:thursday] = self.thursday if self.thursday != nil && self.thursday != ""
        days[:friday] = self.friday if self.friday != nil && self.friday != ""
        days[:saturday] = self.saturday if self.saturday != nil && self.saturday != ""
        days[:sunday] = self.sunday if self.sunday != nil && self.sunday != ""
        return days
    end


end
