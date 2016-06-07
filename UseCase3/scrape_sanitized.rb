#!/usr/bin/env ruby 

require 'watir-webdriver'
require 'uri'
require 'net/http'
require 'tempfile'



#
# 
# Phased browser object driven scraper, mimics real users (almost)
# PHASE 1: Discovery of Docviews Meta
# PHASE 2: Discovery of direct Media links
# PHASE 3: Retrieval of full documents (not implemented)
#
#

site= "http://search"
suser='XXXXXX'
spasswd='YYYYYYY'
#searchbin='/browseterms:fetchresults2/3-d+graphics' # 2 results 
searchbin='/browseterms:fetchresults2/150-hour+requirement' # 9 results ...

puts "[SETUP] Launching Chrome driver instance "
profile = Selenium::WebDriver::Chrome::Profile.new

# Disable plugis to be faster so we do not preview PDFs 
browser = Watir::Browser.new :chrome, :switches => %w[--disable-plugins], :profile => profile

	## Firefox: issues with native events timeouts but YMMV 
	#profile = Selenium::WebDriver::Firefox::Profile.new
	#profile.native_events = false
	#profile['browser.dom.max_script_run_time']=30
	#browser = Watir::Browser.new :firefox, :profile => profile

begin

	puts "[SETUP] Chrome driver *READY*"
	puts "[SETUP] Fetching site: " + site
	browser.goto site


	# set fields
	username = browser.text_field :id => 'username'
	password = browser.text_field :id => 'password'

	# Just checking if we landed where needed
	if ( username.exists? ) 
		username.set suser
	end
	if ( password.exists? ) 
		password.set spasswd
	end

	puts "[SETUP] Value of [Username] is set to : " + username.value
	puts "[SETUP] Value of [Password] is set to : " + password.value.gsub(/[a-zA-Z0-9]/, 'X')


	puts "[LOGIN] Logging in"
	password = browser.text_field :id => 'password'
	browser.link( :id => "submit_0").click



	Watir::Wait.until { browser.text.include? 'Basic Search' }

	puts "[LOGIN] Logged in"

	#browser.link (:text => 'Browse').click
	browser.link(:href => "/index.pagelayout:browse").click
	puts "[PHASE1: DISCOVERY] Browse clicked"

	sleep 5
	Watir::Wait.until { browser.text.include? 'Dissertations and Theses' }
	puts "[PHASE1: DISCOVERY] Found pattern 'Dissertation and Theses' "

	browser.link(:href => '/browse.getdissertations').click
	puts "[PHASE1: DISCOVERY] Disseration clicked"

	sleep 3
	Watir::Wait.until { browser.text.include? 'Dissertations and Theses' }

	browser.link(:href => searchbin).click
	puts "[PHASE1: DISCOVERY] Disseration clicked"

	sleep 3
	Watir::Wait.until { browser.text.include? '0 Selected items' }

	searchlinksRef=browser.links(:href => /fulltextPDF/).collect{ |link| link.href }  
	puts "[PHASE1: DISCOVERY] Docview Metadata Dump"
	searchlinksRef.each { |link| puts "-> " + link }


	puts "[PHASE2: DISCOVERY] Fetching Media links"
	searchlinksRef.each do |link|

		sleep 2
		puts "[PHASE2: DISCOVERY] Full link to docview : " + link

		# One way of doing it:
		docviewAbsolute = URI(link)
		docviewLink=docviewAbsolute.path + "?" + docviewAbsolute.query
		puts "[PHASE2: DISCOVERY] Navigating to  docview : " + docviewLink

		begin
			begin
				browser.link(:href => docviewLink).when_present.click
			rescue Exception => e
				puts "[ERROR] In driver docViewLink :(" + e.message
			else	
				sleep 2
				Watir::Wait.until { browser.text.include? 'Open in PDF Reader' } # broken?
				openpdf=browser.link(:href => /media\/pq\/classic\/.*/)
				puts "[PHASE2: LINK TO CONTENT] " + openpdf.href
				puts "[PHASE3: CONTENT DOWNLOAD] " 


				contenturi = URI.parse(openpdf.href)

				begin
					# No auth  to media server for direct access so siphoning links directly
					response = Net::HTTP.get_response contenturi

					# Randomize file names
					contentfilepath = Tempfile.new('PQPDF-', Dir.pwd).path + ".pdf"
					
					open(contentfilepath, "wb") do |file|
					   file.write(response.body)
					end

					puts "[PHASE3: CONTENT DOWNLOADED] Saved: "  + contentfilepath + "Size: " + File.stat(contentfilepath).size.to_s
				rescue Exception => e
					puts "[ERROR] In driver: phase 3 :(" + e.message
				end
			end

		rescue  Watir::Wait::TimeoutError => te
			puts "[ERROR] In driver :(" + te.message
		rescue  Watir::Exception::UnknownObjectException => uoe
			puts "[ERROR] In driver :(" + uoe.message
		end

		puts "[DEBUG] Backing up"
		browser.back
	
	end

rescue Selenium::WebDriver::Error::ElementNotVisibleError => se
	puts "[ERROR] In driver :(" + se.message
rescue Exception => e
	puts "[ERROR] In driver :(" + e.message
ensure
	browser.close
end

puts "__END__"
