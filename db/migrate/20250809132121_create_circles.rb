class CreateCircles < ActiveRecord::Migration[8.0]
  def change
    create_table :circles do |t|
      t.decimal :center_x
      t.decimal :center_y
      t.decimal :radius

      t.timestamps
    end
  end
end
