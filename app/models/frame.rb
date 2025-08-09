class Frame < ApplicationRecord
  has_many :circles, dependent: :destroy

  validates :width, :height, :center_x, :center_y, presence: true, numericality: true
  validate :no_touching_or_overlap_in_db

  private

  def no_touching_or_overlap_in_db
    return unless bounding_box_valid?

    bb = bounding_box
    overlap = Frame.where.not(id: id)
                    .where("x_range && numrange(?, ?, '[]') AND y_range && numrange(?, ?, '[]')", bb[:min_x], bb[:max_x], bb[:min_y], bb[:max_y])
                    .exists?

    errors.add(:base, "must not touch or intersect another frame") if overlap
  end

  def bounding_box
    half_w = width / 2
    half_h = height / 2

    {
      min_x: center_x - half_w,
      max_x: center_x + half_w,
      min_y: center_y - half_h,
      max_y: center_y + half_h
    }
  end

  def bounding_box_valid?
    width.present? && height.present? && center_x.present? && center_y.present? &&
      width.is_a?(Numeric) && height.is_a?(Numeric) && center_x.is_a?(Numeric) && center_y.is_a?(Numeric)
  end
end
