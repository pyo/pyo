class GroupsController < ApplicationController
  before_filter :authenticate,  :except => [:index, :show, :members] 
  before_filter :find_group,    :except => [:create,:new,:index,:request_group,:pending,:approve,:deny] 
  before_filter :check_user,    :except => [:show,:leave,:join,:index,:request_group, :create,:approve,:deny,:pending,:members,:edit] 
  
  def index
		@title = "Groups"
    @groups = Group.sort_by(params[:sort]).paginate(:per_page => 25, :page => params[:page], :include => :group_category)
    @categories = GroupCategory.all
    respond_to do |format|
      format.html
      format.xml  { render :xml => @groups }
    end
  end

  def join
    if(current_user && !current_user.member_in?(@group))
      @group.users.join(current_user,:MEMBER)
      flash[:notice] = "You have successfully joined #{@group.name}."
    else
      flash[:notice] = "You are already a member of this group."
    end
    redirect_to group_path(@group)
  end
  
  def leave
    @user = User.find(params[:user_id])
    if @user
      if @user==current_user || current_user.is_admin?(@group)
        @group.users.remove(@user)
        flash[:notice] = "You have successfully left #{@group.name}."
        redirect_to group_path(@group)
      else
        flash[:error] = "You are not authorized to remove this user."
        redirect_to group_path(@group)
      end
    else
      flash[:error] = "Invalid user."
      redirect_to group_path(@group)
    end
  end

  def show
		@title = @group.name
    @admins = @group.with_role(:ADMIN) + @group.with_role(:MODERATOR)
    @members = @group.users.paginate(:per_page => 12, :page => 1)
    @photos = @group.photos.paginate(:per_page => 10, :page => 1)
    @videos = @group.videos.paginate(:per_page => 10, :page => 1)
    @tracks = @group.tracks.paginate(:per_page => 10, :page => 1)
    respond_to do |format|
      format.html
      format.xml  { render :xml => @group }
    end
  end

  def new
    @group = Group.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @group }
    end
  end


  def edit
    @admins = @group.with_role(:ADMIN) + @group.with_role(:MODERATOR)
    if @admins.include?(current_user) || current_user.super_user?
      @members = @group.users.paginate(:per_page => 12, :page => 1)
    else
      render :text => current_user.super_user.inspect and return
      deny_access("You do not have sufficient priviledges")
    end
  end

  def create
    @group = Group.new_with_pending(params[:group])
    
    respond_to do |format|
      if @group.save
        membership = Membership.new(:parent_type => "Group", :parent_id => @group.id, :child_type => 'User', :child_id => current_user.id, :status => 'ADMIN')
        membership.save(false)
        #@group.with_approved_scope do
				#@group.users.join(current_user,:ADMIN)
				#end
        flash[:notice] = 'Group request was submitted.'
        format.html { redirect_to(groups_path) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "request_group" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end
  
  def request_group
		@title = "Request New Group"
    @group = Group.new
  end
  
  def pending
    unless current_user.super_user?
      flash[:error] = "You are not authorized for that action!"
      redirect_to "/"
    else
      @groups = Group.pending
    end
  end
  
  def approve
    unless current_user.super_user?
      flash[:error] = "You are not authorized for that action!"
      redirect_to "/"
    else
      # TODO Send Approval DM
      @group = Group.find_pending_by_url(params[:id])
      @group.approved = true
      @group.save
      @group.members.each do |member|
        Activity.send_join_group_notifications(member, @group)
      end
      
      flash[:notice] = "Group was approved."
      redirect_to :back
    end
  end
  
  def deny
    unless current_user.super_user?
      flash[:error] = "You are not authorized for that action!"
      redirect_to "/"
    else
      # TODO Send Denied DM
      @group = Group.find_pending_by_url(params[:id])
      @group.destroy
      flash[:notice] = "Group was denied."
      redirect_to :back
    end
  end
  
  def members
    @admins = @group.with_role(:ADMIN) + @group.with_role(:MODERATOR)
    @members = @group.users.paginate(:per_page => 25, :page => params[:page])
  end
  
  private 
    def find_group
      @group = Group.find_by_url(params[:id])
    end
    
    def check_user
      unless current_user.is_admin?(@group)
        flash[:error] = "You are not authorized for that action."
        redirect_to "/"
      end
    end
  
end
