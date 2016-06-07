#!/usr/bin/env ruby

# This script attempts to "unmask" the user on  linkedin.com 
# When your are not connected to a user you see this  user under 
# "Linkedin Member" title.
#
# It may be possible to perfrom a reverse image search to see if 
# any information was cached by Google on that mark
#
# This script logs to linkedin.com, applies your search pattern
# to get to the desired user (or small company), and performs 
# a reverse image search on google, saving the two snapshots of 
# images locally for visual inspection. 
# 
# Limitation:
# - Reverse image search is not perfect, hence visual verification step.
# - Linkedin.com API does not allow more than 100 results per search
# for free members so use your search foo to zero in on targets within
# this limitation
# - You also need to drive the true browser object because some scrapers 
# did not deal well with the way the site handled javascript postbacks.
# - The site may change in structure any time. 

require 'rubygems'
require 'watir-webdriver'
require 'digest/md5'




# this needs to be from your manual search as first step
search_keywords ='"at FBI"'

li_login='***@gmail.com' # your LI login  creds
li_pass= '***' 


##############
browser = Watir::Browser.new :chrome
puts "Going to site..."
browser.goto "https://www.linkedin.com"

loginbox = browser.text_field :id => 'login-email'
loginbox.set li_login
passbox = browser.text_field :id => 'login-password'
passbox.set li_pass
puts "Entering Creds..."
sleep 1
browser.element(:css => 'input[type=submit][name=submit]').click


puts "Going to Search..."
browser.goto "http://www.linkedin.com/vsearch/p"
sleep 2
mainsearchbox = browser.text_field :id => 'main-search-box'
mainsearchbox.set search_keywords
sleep 1
browser.button(:name => 'search').click

sleep 2

marks=Hash.new
marks_match=0
marks_skip=0
page=0

while true 
    page +=1

    puts "Paging through .... #{page}"
    # linkedin does load refresh just wait a bit. 
    # increase as needed or wait with watir
    sleep rand(4...8)

    browser.element(:css => 'ol[id=results][class=search-results]').elements(:css => 'li').each do |li|
    
        li.images(:class =>'entity-img').each do |img|
            
            image_uri = (URI.parse(img.src)).to_s

            # user images seem to be stored here on LI for now
            # also only match for masked users - this may be relaxed if you just need any users
            if ( image_uri =~ /media.licdn.com/ and li.text =~ /LinkedIn Member/ )
                marks_match += 1
                puts "-"*24

                profile_uri=((img.parent).href).to_s

		puts "\a"
                puts "[*] Identity potential screen @ [ #{image_uri} ]"
                puts "[*] Identity potential profile @ [ #{profile_uri} ]"
                puts li.text.gsub("\n","\n\t")

                # Save in list
                marks[image_uri]=profile_uri
            else
                marks_skip += 1
            end

        end

    end

    # Iteration through pages (until no more exist)
    nextelem=browser.element(:css => 'a[class=page-link][title="Next Page"]')
    break if  ( (not nextelem.exists?) or (page >= 100)  ) # we need to stay under 100 results (10xpage x10 pages)

    nextelem.click
     
end 

### Report for Google 
puts "="*24
puts "Your LI marks list to check in GoogleImages/ (or TinEye) ( marks:#{marks_match} non-marks:#{marks_skip} ) : "
marks.each { |iuri,puri| puts "#{iuri} <-> #{puri} " }

# Pshase II - snapshots


marks.each do  |iuri,puri| 
  
   sleep 4

   # Get hash of profile  URI (key)
   purishot = Digest::MD5.hexdigest(puri)

   # Search Google for image
   browser.goto "https://images.google.com/imghp?hl=en&gws_rd=ssl"
   browser.element(:css => 'span[id=qbi]').click

   sleep 1

   imgbox = browser.text_field :id => 'qbui'
   imgbox.set iuri
   browser.element(:css => 'input[type=submit]').click

   sleep 2

   # If any match found save the screenshot and revisit the LI profile page for secreenshot
   if  ( browser.text.include? 'Tip: Try entering a descriptive word in the search box.' )
       puts "\t[UNMATCHED] #{purishot} :  #{iuri} |  #{puri} " 
   else
       # save google image
       browser.screenshot.save "#{purishot}.image.png"

       # save LI profile image
       browser.goto puri
       browser.screenshot.save "#{purishot}.profile.png"

       # put out verdict
       puts "\t[INSPECT] #{purishot} :  #{iuri} |  #{puri} " 
   end
end
















