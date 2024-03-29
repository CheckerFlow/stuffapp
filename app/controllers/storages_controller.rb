class StoragesController < ApplicationController
  require 'mini_magick'

  include ActiveStorage::SendZip
  include ApplicationHelper
  include StoragesHelper
  require 'will_paginate/array'
  include SharingGroupController
      

  before_action do 
    title("Ablagen")
  end

  before_action :authenticate_user!

  before_action :set_storage, only: [:show, :edit, :update, :destroy, :edit_images, :delete_items, :download_image_attachments]
  before_action :set_room, only: [:new, :create]

  before_action :set_resource, only: [:add_sharing_group_member, :remove_sharing_group_member, :sharing_group_members]    

  # GET /storages
  # GET /storages.json
  def index
    if params[:search]
      #@storages = current_user.storages.where('name LIKE ?', "%#{params[:search]}%")
      #@storages = current_user.storages.where('name LIKE ?', "%#{params[:search]}%").paginate(page: params[:page])
      @storages = all_storages(params[:search]).paginate(page: params[:page])

      @buildings = all_buildings
    else
      #@storages = current_user.storages.all
      #@storages = current_user.storages.all.paginate(page: params[:page])
      @storages = all_storages.paginate(page: params[:page])

      @buildings = all_buildings
    end
  end

  # GET /storages/1
  # GET /storages/1.json
  def show
    process_images(@storage)

    # Redirect images#show if storage has images. 
    if @storage.images.size > 0
      redirect_to storage_image_path(@storage, @storage.images.first)
    end    
  end

  def download_image_attachments

    respond_to do |format|
      format.html { redirect_back(fallback_location: storage_path(@storage), notice: 'Als ZIP Format anfragen.') }
      format.zip { send_zip @storage.images }
    end
    
  end

  # GET /storages/new
  def new
    @storage = Storage.new
    @storage.user_id = current_user.id
  end

  # GET /storages/1/edit
  def edit
    @room = @storage.room    
  end

  def edit_images
  end

  def delete_image_attachment
    @image = ActiveStorage::Blob.find_signed(params[:id])
    @image.attachments.first.purge
    redirect_back(fallback_location: rooms_path)
  end

  def delete_items
    @storage.items.each do
      |item|
      item.destroy
    end

    redirect_back(fallback_location: storage_path(@storage), notice: 'Alle Dinge wurden gelöscht.' )
  end

  # POST /storages
  # POST /storages.json
  def create
    @storage = @room.storages.new(storage_params)
    @storage.user_id = current_user.id

    respond_to do |format|
      if @storage.save

        process_images(@storage)

        format.html { redirect_to @storage, notice: 'Ablage wurde erstellt.' }
        format.json { render :show, status: :created, location: @storage }
      else
        format.html { render :new }
        format.json { render json: @storage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /storages/1
  # PATCH/PUT /storages/1.json
  def update
    respond_to do |format|
      if @storage.update(storage_params)
        
        process_images(@storage)

        format.html { redirect_to room_url(@storage.room), notice: 'Ablage wurde geändert.' }
        format.json { render :show, status: :ok, location: @storage }
      else
        format.html { render :edit }
        format.json { render json: @storage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /storages/1
  # DELETE /storages/1.json
  def destroy
    @room = @storage.room
    @storage.destroy
    respond_to do |format|
      format.html { redirect_to room_url(@room), notice: 'Ablage wurde gelöscht.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_storage
      @storage = Storage.find(params[:id])
    end

    def set_room
      @room = Room.find(params[:room_id])
    end    

    # Set the resource to be shared for the SharingGroupController. Note: Sharables are polymorphic
    def set_resource
      @resource = Storage.find(params[:storage_id])
    end        

    # Never trust parameters from the scary internet, only allow the white list through.
    def storage_params
      params.require(:storage).permit(:user_id, :name, :search, :room_id, images: [])
    end
end
