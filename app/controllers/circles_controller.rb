class CirclesController < ApplicationController
  def create
    frame = Frame.find(params[:frame_id])
    circle = frame.circles.build(circle_params)

    if circle.save
      render json: circle, status: :created
    else
      render json: { errors: circle.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    circle = Circle.find(params[:id])

    if circle.update(circle_params)
      render json: circle, status: :ok
    else
      render json: { errors: circle.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    center_x = params[:center_x]&.to_f
    center_y = params[:center_y]&.to_f
    radius = params[:radius]&.to_f
    frame_id = params[:frame_id]&.to_i

    unless center_x && center_y && radius
      render json: { errors: [ "center_x, center_y and radius are required" ] }, status: :unprocessable_entity and return
    end

    circles = Circle.all
    circles = circles.where(frame_id: frame_id) if frame_id.present?
    circles = circles.within_search_radius(center_x, center_y, radius)

    render json: circles, status: :ok
  end

  private

  def circle_params
    params.require(:circle).permit(:center_x, :center_y, :radius)
  end
end
