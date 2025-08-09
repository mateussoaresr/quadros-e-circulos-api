class Circle < ApplicationRecord
  validates :center_x, :center_y, :radius, presence: true, numericality: true
end
