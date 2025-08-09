# app/validators/circle_within_frame_validator.rb
class CircleWithinFrameValidator < ActiveModel::Validator
  def validate(record)
    frame = record.frame
    return unless frame && record.center_x && record.center_y && record.radius

    if record.center_x - record.radius < 0 ||
       record.center_x + record.radius > frame.width ||
       record.center_y - record.radius < 0 ||
       record.center_y + record.radius > frame.height
      record.errors.add(:base, "Circle must fit completely within its frame")
    end
  end
end
