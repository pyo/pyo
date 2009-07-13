# require 'test_helper'
# 
# class BookingsControllerTest < ActionController::TestCase
#   test "should get index" do
#     get :index
#     assert_response :success
#     assert_not_nil assigns(:events)
#   end
# 
#   test "should get new" do
#     get :new
#     assert_response :success
#   end
# 
#   test "should create event" do
#     assert_difference('Booking.count') do
#       post :create, :booking => { }
#     end
# 
#     assert_redirected_to booking_path(assigns(:event))
#   end
# 
#   test "should show event" do
#     get :show, :id => bookings(:one).to_param
#     assert_response :success
#   end
# 
#   test "should get edit" do
#     get :edit, :id => bookings(:one).to_param
#     assert_response :success
#   end
# 
#   test "should update event" do
#     put :update, :id => bookings(:one).to_param, :event => { }
#     assert_redirected_to booking_path(assigns(:event))
#   end
# 
#   test "should destroy event" do
#     assert_difference('Booking.count', -1) do
#       delete :destroy, :id => bookings(:one).to_param
#     end
# 
#     assert_redirected_to bookings_path
#   end
# end
