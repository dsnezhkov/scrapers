#!/Users/dimas/.rvm/rubies/ruby-2.2.5/bin/ruby

require 'csv'
require 'watir'

$logger = Logger.new('dowagro.run.log')
$results_file="dowagro.zoom.csv"
#$company_url="http://www.zoominfo.com/pic/The-Dow-Chemical-Company/37031826"
#$company_url="http://www.zoominfo.com/pic/Dow-Corning-Corporation/75387797"
$company_url="http://www.zoominfo.com/pic/Dow-AgroSciences-LLC/37031827"
$records=Array.new
page_start=1
page_end=40
sleep_timer=5 # 5s between pages

def dump_csv(log)
	CSV.open(log,'w', 
		 :write_headers=> true,
		 :headers => ["Name","Title","Location","Last Updated"] #< column header
	  ) do |hdr|
			column_header = nil #No header after first insertion
			$records.each do |r|
				data_out = r
				hdr << data_out
			end
	end
end

# Save records in CSV, also for emergency dump of memory data if runtime error encountered with web driver
at_exit do
  puts "Saving Memory records"
  dump_csv($results_file)
end


### Main 


$stderr.puts "[+] Initializing browser ..." 
browser = Watir::Browser.new :chrome

rectotal=0
(page_start..page_end).each do |page|
	reccount=0

	browser.goto($company_url + "?pageNum=#{page}")
   tcontent=browser.element(:xpath, "//div[contains(@class, 'table-content')]")
	if tcontent.exists?
		browser.divs(:class => 'table-content').each do |tc|
			record = { :name => "", :title => "", :location => "", :lastUpdate => "" }
			name=tc.div(:class => 'name')
			title=tc.div(:class => 'title')
			location=tc.div(:class => 'location')
			lastUpdate=tc.div(:class => 'lastUpdate')
			if name.present?
				record[:name] = name.text.gsub(","," ")
			end
			if title.present?
				record[:title] = title.text.gsub(","," ")
			end
			if location.present?
				record[:location] = location.text.gsub(","," ")
			end
			if lastUpdate.present?
				record[:lastUpdate] = lastUpdate.text 
			end

			$records << record.values
			reccount += 1
			rectotal += 1
			$logger.info "[P:#{page}:R:#{reccount}/#{rectotal}]: #{record[:name]}, #{record[:title]}, #{record[:location]}, #{record[:lastUpdate]}"
		end
	end

	sleep sleep_timer
end

