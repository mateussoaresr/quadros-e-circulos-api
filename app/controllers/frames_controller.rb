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

  def show
    frame = Frame.find_by(id: params[:id])
    unless frame
      render json: { errors: [ "Frame not found" ] }, status: :not_found and return
    end

    circles = frame.circles

    render json: {
      id: frame.id,
      center_x: frame.center_x.to_f,
      center_y: frame.center_y.to_f,
      total_circles: circles.count,
      circle_top: circles.order(:center_y).first&.slice(:center_x, :center_y, :radius),
      circle_bottom: circles.order(center_y: :desc).first&.slice(:center_x, :center_y, :radius),
      circle_left: circles.order(:center_x).first&.slice(:center_x, :center_y, :radius),
      circle_right: circles.order(center_x: :desc).first&.slice(:center_x, :center_y, :radius)
    }, status: :ok
  end

  def destroy
    frame = Frame.find_by(id: params[:id])
    unless frame
      return render json: { errors: [ "Frame not found" ] }, status: :not_found
    end

    if frame.circles.exists?
      return render json: { errors: [ "Cannot delete frame with associated circles" ] }, status: :unprocessable_entity
    end

    frame.destroy
    head :no_content
  end
end
