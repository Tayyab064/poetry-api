class SherController < ApplicationController
	before_action :get_sher , only: [:show]

	def do_scrapping
		require 'rubygems' 
		require 'nokogiri' 
		require 'open-uri'
		c = open("http://www.ranjish.com")
		@doc = Nokogiri::HTML(c)
		@categor = @doc.css('.left-box ul li a')

		@shay = []
		@categor.each do |shayiri| 
			if c = open(shayiri['href']) 
			 p shayiri['href'] 
			 cat = shayiri['href'].split('/').last
			 doci = Nokogiri::HTML(c) 
			 if sha = doci.css('.navigation #wp_page_numbers ul .page_info')
				 pag =  sha.text.split.last.to_i 
				 pag.times do |i| 
					 ur = shayiri['href']+'/page/' + (i+1).to_s 
					 p ur
					 if ci = open(ur) 
				 	 	docie = Nokogiri::HTML(ci) 
					 	docie.css(".pbgmain").each do |sha| 
							@shay.push({ 'body' => sha.text.gsub(/\(.*\)/, "").gsub(/\*/,"") , 'category' => cat , 'url' => ur})
					 	end 
					 	docie.css(".pbg").each do |sha| 
							@shay.push({ 'body' => sha.text.gsub(/\(.*\)/, "").gsub(/\*/,"") , 'category' => cat , 'url' => ur})
					 	end 
					 end 
				 end 
			 else 
				 doci.css(".pbgmain").each do |sha| 
					@shay.push({ 'body' => sha.text.gsub(/\(.*\)/, "").gsub(/\*/,"") , 'category' => cat , 'url' => shayiri['href']})
				 end 
				 doci.css(".pbg").each do |sha| 
					@shay.push({ 'body' => sha.text.gsub(/\(.*\)/, "").gsub(/\*/,"") , 'category' => cat , 'url' => shayiri['href']})
				 end
			 end
		 	end
		end

		#.gsub(/\r/,"").gsub(/\n/,"").gsub(/\t/,"")
		p "saving"
		Sher.transaction do
		    @shay.each do |sh|
		    	Sher.find_or_create_by(body: sh["body"]) do |she|
				  she.url = sh["url"]
				 she.category = sh["category"]
				end
		    end
		end
		p "Done"
		render json: {'message' => 'Scrapping Done!'} , status: :ok
	end

	def show
		render json: @sher , status: :ok
	end

	def get_json
		#File.open("public/temp.json","w") do |f|
		#  f.write(tempHash.to_json)
		#end
		data = Sher.all.to_json
		send_data data, :type => 'application/json; header=present', :disposition => "attachment; filename=poetry.json"
	end

	private
	def get_sher
		@sher = Sher.find(params[:id])
	end
end
