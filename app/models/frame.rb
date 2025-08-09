class Frame < ApplicationRecord
  has_many :circles, dependent: :destroy
end
