#!/usr/bin/env ruby

require 'mechanize'
require 'logger'

def dump_links(my_page)
    my_page.links.each do |link|
      text = link.text.strip
      url = link.href
      next unless text.length > 0
      puts text + ' ==> ' +  url
    end
end
a = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }

agent = Mechanize.new { |a| a.log = Logger.new(STDERR); a.user_agent_alias = 'Mac Safari' }
mainpage = agent.get('http://tcmtests.com/')
freebrdtest_page = agent.click(mainpage.link_with(:text => /Free Board Tests/))

biomedgrp=agent.get('http://tcmtests.com/tests/sample.cfm?QuizID=BBM&GroupID=BioMed')
dump_links freebrdtest_page
#page = agent.click page.link_with(:text => /Day/) # Click the link
