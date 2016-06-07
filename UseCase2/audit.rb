#!/usr/bin/env ruby
require 'rubygems'
require 'watir-webdriver'
require 'digest/md5'

tn_login='***'
tn_pass= '***'


download_directory = "#{Dir.pwd}/downloads"
profile = Selenium::WebDriver::Firefox::Profile.new
profile['browser.download.folderList'] = 2 # custom location
profile['browser.download.dir'] = download_directory
profile['browser.helperApps.neverAsk.saveToDisk'] = "application/octet-stream, application/pdf"
 
browser = Watir::Browser.new :firefox, :profile => profile

### Main site
browser.goto "https://support/center/"

loginbox = browser.text_field :name => 'auth_user'
loginbox.set tn_login
passbox = browser.text_field :name => 'auth_pass'
passbox.set tn_pass
sleep 1
browser.button(:name => 'submit').click
sleep 2


### Compliance downloads
browser.goto 'https://support/center/index.php?x=&mod_id=190'

## Get all categories and respective URLs
cats=Hash.new
browser.h3s(:class => 'nomt').each do |h3|
    cat_name=h3.text.gsub(' ','_');
    cats[cat_name]=h3.link.href
end

### Each category
cats.each do |catname,caturl| 
    
    puts "Fetching category #{catname} from  #{caturl}"

    browser.goto caturl
    sleep 1

    tn_links=Array.new
    browser.links.each do |link|
        tn_links.push(link.href) if ( link.href =~ /dl_secure.php/ )
    end

    ## Each download link
    tn_links.each do |link|
        browser.goto(link)
        sleep 1
        browser.button(:name => 'accept').click
        puts "Went to #{link}"
        sleep 1
    end
end
