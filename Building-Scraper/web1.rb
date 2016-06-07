#!/usr/bin/env ruby


require 'nokogiri'
require 'open-uri'


open("http://tcmtests.com").read
hdoc=Nokogiri::HTML(open("http://tcmtests.com").read)
hdoc.xpath("/html/body/table[@id='Table_01']/tbody/tr[3]/td/table[@id='main']/tbody/tr[1]/td[2]/table[@id='main_embedded']/tbody/tr/td[1]/table[@id='left_column']/tbody/tr[2]/td[2]/table[@id='goldBox2a']/tbody/tr[2]/td/a[1]").each do |node|
  puts node
end


