class SearchesController < ApplicationController
    
    # 検索機能
    def search
        @model = params[:model]
        # if @model == "Nickname"
            @users = User.lookup(params[:search], params[:word])
            # binding.pry
           # @tag = Tag.lookup(params[:search], params[:word])
        # end
    end
end
