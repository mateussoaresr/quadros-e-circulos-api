class Circle < ApplicationRecord
  belongs_to :frame
  validates :center_x, :center_y, :radius, presence: true, numericality: true
end
