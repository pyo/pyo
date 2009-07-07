class GroupsController < ApplicationController
  before_filter :authenticate, :except => [:index, :show] 
  before_filter :find_group, :except => [:create,:new,:index] 
  
  def index
    @groups = Group.find(:all)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @groups }
    end
  end

  def show

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

  end

  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(@group) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
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
  
  private 
    def find_group
      @group = Group.find(params[:id])
    end
    
    def check_user
      unless current_user.is_admin?(@group)
        flash[:error] = "You are not authorized for that action."
        redirect_to "/"
      end
    end
  
end
