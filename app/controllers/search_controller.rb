class SearchController < ApplicationController
	def search_category
		@sher = Sher.where('category ~* ?' , params[:category])
		render json: @sher , status: :ok
	end

	def search_sher
		if params[:title].present?
			@sher = Sher.search_by_body(params[:title])
			render json: @sher , status: :ok
		else
			render json: {'message' => 'Search title missing !'} , status: :unprocessable_entity
		end
	end
end
