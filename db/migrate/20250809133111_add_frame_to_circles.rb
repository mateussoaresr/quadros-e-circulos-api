class AddFrameToCircles < ActiveRecord::Migration[8.0]
  def change
    add_reference :circles, :frame, null: false, foreign_key: true
  end
end
