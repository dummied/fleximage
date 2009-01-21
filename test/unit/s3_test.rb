require File.dirname(__FILE__) + '/../test_helper.rb'    
require 'net/http'  

class S3Test < Test::Unit::TestCase 
   
  def test_should_save_master_images_to_s3_if_option_passed
    @photo = PhotoS3.create!(:image_file => files(:photo))
    assert_kind_of Net::HTTPOK, http_response_for(@photo.file_path)
  end 
  
  def test_should_destroy_from_s3_when_record_destroyed
    @photo = PhotoS3.create!(:image_file => files(:photo), :id => 2)
    assert_kind_of Net::HTTPOK, http_response_for(@photo.file_path)
    @photo.destroy    
    assert_kind_of Net::HTTPNotFound, http_response_for(@photo.file_path)
  end  
  
  protected
    def http_response_for(url)
      url = URI.parse(url)
      Net::HTTP.start(url.host, url.port) {|http| http.request_head(url.path) }
    end
  
  
end