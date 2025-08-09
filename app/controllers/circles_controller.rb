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

  private

  def circle_params
    params.require(:circle).permit(:center_x, :center_y, :radius)
  end
end
