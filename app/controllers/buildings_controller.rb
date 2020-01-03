class BuildingsController < ApplicationController
  include ActiveStorage::SendZip
  include ApplicationHelper

  before_action :authenticate_user!
  before_action :set_building, only: [:show, :edit, :update, :destroy, :edit_images, :download_image_attachments]


  # GET /buildings
  # GET /buildings.json
  def index
    if params[:search]
      @buildings = current_user.buildings.where('name LIKE ?', "%#{params[:search]}%")
    else
      @buildings = current_user.buildings.all
    end
  end

  # GET /buildings/1
  # GET /buildings/1.json
  def show
    @rooms = @building.rooms.all
  end

  def download_image_attachments

    respond_to do |format|
      format.html { redirect_back(fallback_location: building_path(@building), notice: 'Als ZIP Format anfragen.') }
      format.zip { send_zip @building.images }
    end
    
  end    

  # GET /buildings/new
  def new
    @building = Building.new
    @building.user_id = current_user.id
  end

  # GET /buildings/1/edit
  def edit
  end

  def delete_image_attachment
    @image = ActiveStorage::Blob.find_signed(params[:id])
    @image.attachments.first.purge
    redirect_back(fallback_location: buildings_path)
  end  

  # POST /buildings
  # POST /buildings.json
  def create
    @building = Building.new(building_params)
    @building.user_id = current_user.id

    respond_to do |format|
      if @building.save

        process_images(@building)

        format.html { redirect_to @building, notice: 'Gebäude wurde erstellt.' }
        format.json { render :show, status: :created, location: @building }
      else
        format.html { render :new }
        format.json { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /buildings/1
  # PATCH/PUT /buildings/1.json
  def update
    respond_to do |format|
      if @building.update(building_params)

        process_images(@building)

        format.html { redirect_to building_url(@building), notice: 'Gebäude wurde geändert.' }
        format.json { render :show, status: :ok, location: @building }
      else
        format.html { render :edit }
        format.json { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /buildings/1
  # DELETE /buildings/1.json
  def destroy
    @building.images.each do 
      |image|
      image.purge
    end

    @building.destroy
    respond_to do |format|
      format.html { redirect_to buildings_url, notice: 'Building was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_building
      @building = current_user.buildings.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def building_params
      params.require(:building).permit(:name, :user_id, :search, images: [])
    end
end
