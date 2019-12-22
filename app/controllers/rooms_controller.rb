class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room, only: [:show, :edit, :update, :destroy, :edit_images]

  # GET /rooms
  # GET /rooms.json
  def index
    if params[:search]
      @rooms = current_user.rooms.where('name LIKE ?', "%#{params[:search]}%")
    else
      @rooms = current_user.rooms.all
    end    
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    @storages = @room.storages.all
  end

  # GET /rooms/new
  def new
    @room = Room.new
    @room.user_id = current_user.id
  end

  # GET /rooms/1/edit
  def edit
  end

  def edit_images
  end

  def delete_image_attachment
    @image = ActiveStorage::Blob.find_signed(params[:id])
    @image.attachments.first.purge
    redirect_back(fallback_location: rooms_path)
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(room_params)
    @room.user_id = current_user.id

    respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: 'Raum wurde erfolgreich erstellt.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update    
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to room_url(@room), notice: 'Raum wurde erfolgreich geändert.' }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    
    @room.images.each do 
      |image|
      image.purge
    end

    @room.destroy
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: 'Raum wurde erfolgreich gelöscht.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = current_user.rooms.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def room_params
      params.require(:room).permit(:user_id, :name, :search, images: [])
    end
end
