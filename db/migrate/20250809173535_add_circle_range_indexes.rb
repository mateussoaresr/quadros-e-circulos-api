class AddCircleRangeIndexes < ActiveRecord::Migration[8.0]
  def change
    enable_extension "btree_gist"

    add_column :circles, :x_range, :numrange, as: "numrange(center_x - radius, center_x + radius, '[]')", stored: true
    add_column :circles, :y_range, :numrange, as: "numrange(center_y - radius, center_y + radius, '[]')", stored: true

    add_index :circles, :x_range, using: :gist
    add_index :circles, :y_range, using: :gist
  end
end
