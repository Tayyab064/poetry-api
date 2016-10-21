class SherController < ApplicationController
	before_action :get_sher , only: [:show]

	def do_scrapping
		require 'rubygems' 
		require 'nokogiri' 
		require 'open-uri'
		#require 'selenium-webdriver'
		#require 'phantomjs'
		#require 'watir'

		c = open("http://www.ranjish.com")
		@doc = Nokogiri::HTML(c)
		@categor = @doc.css('.left-box ul li a')

		@shay = []
		@categor.each do |shayiri| 
			if c = open(shayiri['href']) 
			 p shayiri['href'] 
			 cat = shayiri['href'].split('/').last
			 if cat.include?('.html')
			 	cat = shayiri['href'].split('/')[shayiri['href'].split('/').count-2]
			 end
			 doci = Nokogiri::HTML(c) 
			 if sha = doci.css('.navigation #wp_page_numbers ul .page_info')
				 pag =  sha.text.split.last.to_i 
				 pag.times do |i| 
					 ur = shayiri['href']+'/page/' + (i+1).to_s 
					 p ur
					 if ci = open(ur) 
				 	 	docie = Nokogiri::HTML(ci) 
					 	docie.css(".pbgmain").each do |sha| 
							@shay.push({ 'body' => sha.text.gsub(/\(.*\)/, "").gsub(/\*/,"").gsub(/Watch Video/,"") , 'category' => cat , 'url' => ur})
					 	end 
					 	docie.css(".pbg").each do |sha| 
							@shay.push({ 'body' => sha.text.gsub(/\(.*\)/, "").gsub(/\*/,"").gsub(/Watch Video/,"") , 'category' => cat , 'url' => ur})
					 	end 
					 end 
				 end 
			 else 
				 doci.css(".pbgmain").each do |sha| 
					@shay.push({ 'body' => sha.text.gsub(/\(.*\)/, "").gsub(/\*/,"").gsub(/Watch Video/,"") , 'category' => cat , 'url' => shayiri['href']})
				 end 
				 doci.css(".pbg").each do |sha| 
					@shay.push({ 'body' => sha.text.gsub(/\(.*\)/, "").gsub(/\*/,"").gsub(/Watch Video/,"") , 'category' => cat , 'url' => shayiri['href']})
				 end
			 end
		 	end
		end

		@poets = []
		#rek = open("https://rekhta.org/poets")
		#@rek_doc = Nokogiri::HTML(rek)
		#@rek_categor = @rek_doc.css('.table-filter li a')
		#@rek_categor.each do |rek|
		#	p "https://rekhta.org" + rek['href']
		#	po = "https://rekhta.org" + rek['href']
		#	rek_in = open(po)
		#	@rek_doc_in = Nokogiri::HTML(rek_in)
		#	@rek_categor_in = @rek_doc_in.css('td a')
		#	@rek_categor_in.each do |poet|
		#		p "Poet"
		#		p poet.text
		#	end
		#end

		#pagi = ['a' ,'b' , 'c' , 'd' , 'e' , 'f' , 'g' , 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'x', 'y', 'z']
		pagi = []
		pagi.each do |pag|
			p 'https://rekhta.org/poets?startswith='+pag
			rek = open('https://rekhta.org/poets?startswith='+pag)
			@rek_doc = Nokogiri::HTML(rek)
			@rek_categor = @rek_doc.css('tr')
			@rek_categor.each do |poe|
				poet_nam = poe.text.gsub(/\d/ , '').gsub(',' , '').gsub('.' , '')
				if poet_nam.split(' ').count > 1
					tem = ''
					poet_nam.split(' ').each do |sp|
						if tem.length < 1 
							tem = sp
						elsif sp.gsub(' ' , '').length > 0 
							tem = tem + '-' + sp
						end
					end
					@poets.push(tem.squish)
				end
			end
		end


		@poets.each do |link_to_poet|
			#p 'https://rekhta.org/poets/' + link_to_poet
			if rek = open('https://rekhta.org/poets/' + link_to_poet)
				@rek_doc = Nokogiri::HTML(rek)
				@rek_categor = @rek_doc.css("tr > td").first
				ghaza = @rek_categor['href']
				p ghaza

				if rek = open('https://rekhta.org/ghazals/aandhiyaan-gam-kii-chaliin-aur-karb-baadal-chhaa-gae-aabida-urooj-ghazals')
					@rek_doc = Nokogiri::HTML(rek)
					@rek_categor = @rek_doc.css('.RawPoemDisplay div .DivLine')
					ghaza = @rek_categor.text
					p 'Single Sher'
					p ghaza
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
		File.open("public/poetry.json", "w") do |f| 
		  f.write(@shay.to_json)
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

	def get_category
		data = Sher.all.pluck(:category).uniq
		render json: data , status: :ok
	end

	private
	def get_sher
		@sher = Sher.find(params[:id])
	end
end
