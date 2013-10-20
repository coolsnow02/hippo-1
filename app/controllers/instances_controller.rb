class InstancesController < ApplicationController
  # GET /instances
  # GET /instances.json
  before_filter :find_provider, :unless => proc{ request.xhr?   }
  def index
    @instances = @provider.instances.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @instances }
    end
  end

  # GET /instances/1
  # GET /instances/1.json
  def show
    @instance = Instance.find(params[:id])
    @flavor = Flavor.find_by_flavor_id(@instance.flavor_id)
    @image = Image.find_by_image_id(@instance.image_id)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @instance }
    end
  end

  # GET /instances/new
  # GET /instances/new.json
  def new
    @flavours = @provider.get_flavors
    puts "getting the flavors #{@flavours.inspect}"
    @images = @provider.get_images
    puts "getting the flavors #{@images.inspect}"
    @instance = @provider.instances.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @instance }
    end
  end

  # GET /instances/1/edit
  def resize_server
    @flavours = @provider.get_flavors
    puts "getting the flavors #{@flavours.inspect}"
    @instance = @provider.instances.find(params[:id])
  end

  # POST /instances
  # POST /instances.json
  def create
    @instance = @provider.instances.new(params[:instance])
    @instance.state = "Building"
    respond_to do |format|
      if @instance.save
        @instance.create_instance(@provider.connect!)
        format.html { redirect_to cloud_provider_instance_path(@provider,@instance), notice: 'Instance was successfully created.' }
        format.json { render json: @instance, status: :created, location: @instance }
      else
        format.html { render action: "new" }
        format.json { render json: @instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /instances/1
  # PUT /instances/1.json
  def update
    if request.xhr?
      @instance = Instance.find(params[:id])
    else
      @instance = @provider.instances.find(params[:id])
    end
    respond_to do |format|
      if @instance.update_attributes(params[:instance])
        @instance.resize_instance(@provider.connect!)
        format.html { redirect_to @instance, notice: 'Instance was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instances/1
  # DELETE /instances/1.json
  def destroy
    @instance = @provider.instances.find(params[:id])
    @instance.destroy

    respond_to do |format|
      format.html { redirect_to instances_url }
      format.json { head :no_content }
    end
  end

  def instance_status
  @instance = Instance.find(params[:id])
  respond_to do | format|
      format.json { render :json => {:state => @instance.state, :progress => @instance.progress,
                                      :publicip => instance.public_ip, :privateip => instance.private_ip}}
    end
  end

  def start
    @instance = Instance.find params[:id]
    @instance.start_aws_instance(@provider.connect!)
    redirect_to :back
  end

  def stop
    @instance = Instance.find params[:id]
    @instance.stop_aws_instance(@provider.connect!)
    redirect_to :back
  end

  def reboot
    @instance = Instance.find params[:id]
    InstanceOperations.reboot_instances(@provider.connect!, @instance)
    redirect_to :back
  end

  private

  def find_provider
    @provider = current_user.cloud_providers.find_by_id(params[:cloud_provider_id])
    redirect_to root_path, :alert => "Sorry you are restricted to use this instance !!!" and return unless @provider.present?
  end
end
