class ShelvesController < ApplicationController
  # GET /shelves
  # GET /shelves.xml
  def index
    @shelves = Shelf.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shelves.to_xml(:include => :books) }
    end
  end

  # GET /shelves/1
  # GET /shelves/1.xml
  def show
    @shelf = Shelf.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shelf.to_xml(:include => :books) }
    end
  end

  # GET /shelves/new
  # GET /shelves/new.xml
  def new
    @shelf = Shelf.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shelf }
    end
  end

  # GET /shelves/1/edit
  def edit
    @shelf = Shelf.find(params[:id], :include => :books)
    respond_to do |format|
      format.xml { render :xml => @shelf }
      format.html
    end
  end

  # POST /shelves
  # POST /shelves.xml
  def create
    @shelf = Shelf.new(params[:shelf])

    respond_to do |format|
      if @shelf.save
        flash[:notice] = 'Shelf was successfully created.'
        format.html { redirect_to(@shelf) }
        format.xml  { render :xml => @shelf, :status => :created, :location => @shelf }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shelf.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shelves/1
  # PUT /shelves/1.xml
  def update
    @shelf = Shelf.find(params[:id])

    respond_to do |format|
      if @shelf.update_attributes(params[:shelf])
        flash[:notice] = 'Shelf was successfully updated.'
        format.html { redirect_to(@shelf) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shelf.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shelves/1
  # DELETE /shelves/1.xml
  def destroy
    @shelf = Shelf.find(params[:id])
    @shelf.destroy

    respond_to do |format|
      format.html { redirect_to(shelves_url) }
      format.xml  { head :ok }
    end
  end
end
