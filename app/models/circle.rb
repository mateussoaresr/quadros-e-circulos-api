class Circle < ApplicationRecord
  belongs_to :frame, required: true
  validates :frame, presence: true
  validates :center_x, :center_y, :radius, presence: true, numericality: true

  validates_with CircleWithinFrameValidator
  validate :no_overlap_with_saved_circles

  scope :within_search_radius, ->(cx, cy, r) {
    bb_min_x = cx - r
    bb_max_x = cx + r
    bb_min_y = cy - r
    bb_max_y = cy + r

    where("x_range && numrange(?, ?, '[]') AND y_range && numrange(?, ?, '[]')",
      bb_min_x, bb_max_x, bb_min_y, bb_max_y
    ).where(
      "SQRT(POWER(center_x - ?, 2) + POWER(center_y - ?, 2)) + radius <= ?",
      cx, cy, r
    )
  }

  private

  def no_overlap_with_saved_circles
    return unless frame_id
    return if center_x.nil? || center_y.nil? || radius.nil? # só segue se campos existem

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
