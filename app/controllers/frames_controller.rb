class FramesController < ApplicationController
  def create
    frame_params = params.require(:frame).permit(
      :center_x,
      :center_y,
      :width,
      :height,
      circles: [ :center_x, :center_y, :radius ]
    )

    circles_attrs = frame_params.delete(:circles) || []

    # Valida sobreposição entre círculos recebidos
    validator = Circles::BatchOverlapValidator.new(circles_attrs.map(&:to_h))
    unless validator.valid?
      render json: { errors: validator.errors }, status: :unprocessable_entity
      return
    end

    frame = Frame.new(frame_params)

    Frame.transaction do
      if frame.save
        circles_attrs.each { |attrs| frame.circles.create!(attrs) }
        render json: frame.as_json(include: :circles), status: :created
      else
        render json: { errors: frame.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
