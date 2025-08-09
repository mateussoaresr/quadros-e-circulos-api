class CircleWithinFrameValidator < ActiveModel::Validator
  def validate(record)
    frame = record.frame
    return unless frame && record.center_x && record.center_y && record.radius

    frame_min_x = frame.center_x - frame.width / 2.0
    frame_max_x = frame.center_x + frame.width / 2.0
    frame_min_y = frame.center_y - frame.height / 2.0
    frame_max_y = frame.center_y + frame.height / 2.0

    if (record.center_x - record.radius) < frame_min_x ||
       (record.center_x + record.radius) > frame_max_x ||
       (record.center_y - record.radius) < frame_min_y ||
       (record.center_y + record.radius) > frame_max_y
      record.errors.add(:base, "Circle must fit completely within its frame")
    end
  end
end
