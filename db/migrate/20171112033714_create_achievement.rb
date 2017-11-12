class CreateAchievement < ActiveRecord::Migration
  def change
    create_table :achievements do |t|
      t.text :title
      t.text :description
      t.integer :privacy
      t.boolean :featured
      t.string :cover_image
    end
  end
end
