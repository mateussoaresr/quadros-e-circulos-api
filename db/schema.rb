# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_09_172507) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"

  create_table "circles", force: :cascade do |t|
    t.decimal "center_x"
    t.decimal "center_y"
    t.decimal "radius"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "frame_id", null: false
    t.index ["frame_id"], name: "index_circles_on_frame_id"
  end

  create_table "frames", force: :cascade do |t|
    t.decimal "width"
    t.decimal "height"
    t.decimal "center_x"
    t.decimal "center_y"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "x_range", type: :numrange, as: "numrange((center_x - (width / (2)::numeric)), (center_x + (width / (2)::numeric)), '[]'::text)", stored: true
    t.virtual "y_range", type: :numrange, as: "numrange((center_y - (height / (2)::numeric)), (center_y + (height / (2)::numeric)), '[]'::text)", stored: true
    t.index ["x_range"], name: "index_frames_on_x_range", using: :gist
    t.index ["y_range"], name: "index_frames_on_y_range", using: :gist
  end

  add_foreign_key "circles", "frames"
end
