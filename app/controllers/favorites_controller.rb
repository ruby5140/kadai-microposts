class FavoritesController < ApplicationController
  def create
    micropost = Micropost.find(params[:micropost_id])
    #パラメーターとして、[:micropost_id]を受け取って、Micropostのオブジェクトをfind

    current_user.favorite(micropost)
    #favoriteメソッドを使って上でfindしたMicropostをお気に入り
    
    flash[:success] = '投稿をお気に入りしました。'

    redirect_back(fallback_location: root_url)
    #fallback_locationを指定
  end

  def destroy
    micropost = Micropost.find(params[:micropost_id])
    current_user.unfavorite(micropost)
    flash[:success] = 'お気に入りを解除しました。'
    redirect_back(fallback_location: root_url)
  end
end
