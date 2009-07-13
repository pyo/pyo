# require 'test_helper'
# 
# class AdsControllerTest < ActionController::TestCase
#   test "should get index" do
#     get :index
#     assert_response :success
#     assert_not_nil assigns(:ads)
#   end
# 
#   test "should get new" do
#     get :new
#     assert_response :success
#   end
# 
#   test "should create ad" do
#     assert_difference('Ad.count') do
#       post :create, :ad => { }
#     end
# 
#     assert_redirected_to ad_path(assigns(:ad))
#   end
# 
#   test "should show ad" do
#     get :show, :id => ads(:one).to_param
#     assert_response :success
#   end
# 
#   test "should get edit" do
#     get :edit, :id => ads(:one).to_param
#     assert_response :success
#   end
# 
#   test "should update ad" do
#     put :update, :id => ads(:one).to_param, :ad => { }
#     assert_redirected_to ad_path(assigns(:ad))
#   end
# 
#   test "should destroy ad" do
#     assert_difference('Ad.count', -1) do
#       delete :destroy, :id => ads(:one).to_param
#     end
# 
#     assert_redirected_to ads_path
#   end
# end
