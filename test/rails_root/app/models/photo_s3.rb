class PhotoS3 < ActiveRecord::Base    
  
  acts_as_fleximage :s3 => true
  
end