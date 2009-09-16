class GroupCategoriesController < ApplicationController
  def show
    @group_category = GroupCategory.find(params[:id])
		@title = "Groups &mdash; #{@group_category.name}"
    @groups = @group_category.groups.paginate(:per_page => 25, :page => params[:page])
    @categories = GroupCategory.all
  end
end
