class SearchesController < ApplicationController
    
    # 検索機能
    def search
            @users = User.lookup(params[:search], params[:word])
    end
end
