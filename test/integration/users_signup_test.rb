require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  test "invalid signup information" do
    get signup_path
    
    assert_no_difference 'User.count' do
      
      post users_path, user: { name:"", 
                               email: "user@invalid", 
                               password: "foo", 
                               password_confirmation: "bar" }
      
    end
    #after_count = User.count
    #assert_equal before_count, after_count
    assert_template 'users/new'
    
  end
  
  test "valid signup information" do
    get signup_path
    
    assert_difference 'User.count', 1 do
      
      post users_path, user: { name:"Example User", 
                               email: "user@example.com", 
                               password: "foobar", 
                               password_confirmation: "foobar" }
      
    end
    #after_count = User.count
    #assert_equal before_count, after_count
    #follow_redirect!
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    
    log_in_as(user)
    assert_not is_logged_in?
    get edit_account_activation_path("invalid token")
    assert_not is_logged_in?
    
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    
    get edit_account_activation_path(user.activation_token, email: user.email)
    user.reload
    assert user.activated?
    follow_redirect!
    
    assert_template 'users/show'
    assert is_logged_in?
    
  end
  
  
  
end
