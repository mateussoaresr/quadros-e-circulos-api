class Circle < ApplicationRecord
  belongs_to :frame, required: true
  validates :frame, presence: true
  validates_associated :frame
  validates :center_x, :center_y, :radius, presence: true, numericality: true

  validates_with CircleWithinFrameValidator
  validate :no_overlap_with_saved_circles

  def no_overlap_with_saved_circles
    return unless frame_id

    existing = Circle.where(frame_id: frame_id).where.not(id: id)
    if existing.any? { |c| overlaps?(c) }
      errors.add(:base, "overlaps with an existing circle in this frame")
    end
  end

  def overlaps?(other)
    dist = Math.sqrt((center_x - other.center_x)**2 + (center_y - other.center_y)**2)
    dist <= (radius + other.radius)
  end
end
