class ApplicationController < ActionController::Base
  include RoomsHelper

  def default_url_options
    if Rails.env.development?
      {:host => "3000-salmon-ptarmigan-1jsovqe2.ws-eu25.gitpod.io"}
    else  
      {}
    end
  end

  def after_sign_in_path_for(resource)
    if (all_rooms.count == 0)
      stored_location_for(resource) || pages_home_path
    else 
      search_search_path
    end    
  end  
end
