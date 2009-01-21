class CreatePhotoS3s < ActiveRecord::Migration
  def self.up
    create_table :photo_s3s do |t|
      t.string :image_filename
      t.integer :image_width
      t.integer :image_height

      t.timestamps
    end
  end

  def self.down
    drop_table :photo_s3s
  end
end
