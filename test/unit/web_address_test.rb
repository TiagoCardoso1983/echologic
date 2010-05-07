require 'test_helper'

class WebAddressTest < ActiveSupport::TestCase
  
  # Web profiles mustn't be saved empty.
  def test_no_empty_saving
    w = WebAddress.new
    assert !w.save
  end

  # Web profile model has to provide which profiles are available.
  def test_web_addresses
    assert_kind_of [Array], WebAddress.web_addresses
  end

  # Web profiles has to belong to a user.
  def test_presence_of_user
    assert_kind_of User, web_addresses(:joe_twitter).user
  end
  
  def test_unvalid_email_address
    w = WebAddress.new
    w.user_id = User.first.id
    w.web_address = WebAddress.web_addresses("email").first
    w.location = "http://facebook.com"
    assert !w.save
  end
  
  def test_unvalid_location_path
    w = WebAddress.new
    w.user_id = User.first.id
    w.web_address = WebAddress.web_addresses("homepage").first
    w.location = "me@me.com"
    assert !w.save
  end

end
