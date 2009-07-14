class BookingsController < ApplicationController
  before_filter :find_event
	before_filter :authenticate, :only=>[:new,:create,:edit,:update]
  before_filter :find_user, :only=>[:show,:index]
	
  # GET /events
  # GET /events.xml
  def index
    @events = Booking.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end
  
  def rate
    @event.rate_it( params[:rate_value], current_user.id )
    respond_to do |wants|
      wants.json { 
        render :json => @event
      }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
	
    @event = Booking.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.xml
  def create
    @event = current_user.bookings.new(params[:booking])

    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to([current_user, @event]) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update

    respond_to do |format|
      if @event.update_attributes(params[:booking])
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to([current_user,@event]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end

  private
    def find_event
      @event = Booking.find(params[:id]) if params[:id]
    end
end
