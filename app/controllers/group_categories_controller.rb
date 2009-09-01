class GroupCategoriesController < ApplicationController
  def show
    @group_category = GroupCategory.find(params[:id])
    @groups = @group_category.groups.paginate(:per_page => 25, :page => params[:page])
    @categories = GroupCategory.all
  end
end
