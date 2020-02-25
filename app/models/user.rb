class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
            :recoverable, :rememberable, :validatable

    has_many :reviews
    has_many :dishes
    has_one_attached :avatar
    has_many :orders
    has_one :address
    has_one :availability

    def name
        return "#{first_name} #{last_name}"
    end

    def get_display_picture
        return self.avatar.attached? ? self.avatar : "default-profile.png"
    end

end
