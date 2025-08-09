class AddFrameRangeIndexes < ActiveRecord::Migration[8.0]
  def change
    enable_extension "btree_gist" unless extension_enabled?("btree_gist")

    add_column :frames, :x_range, :numrange, as: "numrange(center_x - width/2, center_x + width/2, '[]')", stored: true
    add_column :frames, :y_range, :numrange, as: "numrange(center_y - height/2, center_y + height/2, '[]')", stored: true

    add_index :frames, :x_range, using: :gist, if_not_exists: true
    add_index :frames, :y_range, using: :gist, if_not_exists: true
  end
end
