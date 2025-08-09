class Circle < ApplicationRecord
  belongs_to :frame, required: true
  validates :frame, presence: true
  validates_associated :frame
  validates :center_x, :center_y, :radius, presence: true, numericality: true

  validates_with CircleWithinFrameValidator
  validate :no_overlap_with_saved_circles

  private

  def no_overlap_with_saved_circles
    return unless frame_id

    bb = bounding_box
    overlap = Circle.where(frame_id: frame_id)
                    .where.not(id: id)
                    .where("x_range && numrange(?, ?, '[]') AND y_range && numrange(?, ?, '[]')", bb[:min_x], bb[:max_x], bb[:min_y], bb[:max_y])
                    .exists?

    errors.add(:base, "overlaps with an existing circle in this frame") if overlap
  end

  def bounding_box
    {
      min_x: center_x - radius,
      max_x: center_x + radius,
      min_y: center_y - radius,
      max_y: center_y + radius
    }
  end
end
