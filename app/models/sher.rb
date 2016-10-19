class Sher < ActiveRecord::Base
	include PgSearch
  	pg_search_scope :search_by_body, :against => :body
end
