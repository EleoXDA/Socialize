class UsersController < ApplicationController
  def index
    @users = User.all
    if params[:location].present? && params[:query].present?
      @users = @users.where(location: params[:location]).where("nickname ILIKE ?", "%#{params[:query]}%")
    elsif params[:location].present?
      @users = @users.where(location: params[:location])
    elsif params[:query].present?
      @users = User.where("nickname ILIKE ?", "%#{params[:query]}%")
    end
    @users = @users.joins(:languages).where(languages: {name: params[:language] }) if params[:language]

    locations = User.distinct.pluck(:location)
    @location_filters = []
    locations.each do |location|
      if !location.nil?
        @location_filters << location
      end
    end

    @chat_requests = ChatRequest.where(asker: current_user).or(ChatRequest.where(receiver: current_user))
    @pending_chat_requests = @chat_requests.filter{ |chat| chat.pending? }
    @confirmed_chat_requests = @chat_requests.filter{ |chat| chat.confirmed?}
    @pinned_chat_requests = @confirmed_chat_requests.filter{ |chat|
      if current_user == chat.asker
        chat.receiver_is_pinned == true
      else
        chat.asker_is_pinned == true
      end
    }
    @chat_request = ChatRequest.new
    @markers = @users.geocoded.map do |user|
      {
        lat: user.latitude,
        lng: user.longitude,
        info_window: render_to_string(partial: "info_window", locals: { user: user })
      }
    end
  end

  def show
  end

  def profile
    @user = current_user
    @user_languages = current_user.languages.map do |language|
      language.name
    end
    @user_languages = @user_languages.to_sentence
  end

  def edit
    @user = current_user
    @languages = @user.languages.build
  end

  def update
    @user = current_user
    language_id = params[:user][:languages][:id]
    @languages = @user.user_languages.build(language_id: language_id)

    if @user.update(sign_up_params)
      redirect_to users_path, status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:location, :linkedin_url)
  end

  def user_params
    params.require(:user).permit(:photo, :location)
  end
end
