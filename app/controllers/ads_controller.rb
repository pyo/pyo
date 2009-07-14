class AdsController < ApplicationController
	before_filter :find_ad
	before_filter :authenticate, :only=>[:new,:create,:edit,:update]
  before_filter :find_user, :only=>[:show,:index]
  # GET /ads
  # GET /ads.xml
  def index
    @ads = Ad.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ads }
    end
  end
  
  def rate
    @ad.rate_it( params[:rate_value], current_user.id )
    respond_to do |wants|
      wants.json { 
        render :json => @ad
      }
    end
  end

  # GET /ads/1
  # GET /ads/1.xml
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ad }
    end
  end

  # GET /ads/new
  # GET /ads/new.xml
  def new
    @ad = Ad.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ad }
    end
  end

  # GET /ads/1/edit
  def edit
  end

  # POST /ads
  # POST /ads.xml
  def create
    @ad = current_user.ads.new(params[:ad])

    respond_to do |format|
      if @ad.save
        flash[:notice] = 'Ad was successfully created.'
        format.html { redirect_to([current_user,@ad]) }
        format.xml  { render :xml => @ad, :status => :created, :location => @ad }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ad.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ads/1
  # PUT /ads/1.xml
  def update

    respond_to do |format|
      if @ad.update_attributes(params[:ad])
        flash[:notice] = 'Ad was successfully updated.'
        format.html { redirect_to([current_user,@ad]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ad.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ads/1
  # DELETE /ads/1.xml
  def destroy
    @ad.destroy

    respond_to do |format|
      format.html { redirect_to(ads_url) }
      format.xml  { head :ok }
    end
  end

  private
    def find_ad
      @ad = Ad.find(params[:id]) if params[:id]
    end
end
