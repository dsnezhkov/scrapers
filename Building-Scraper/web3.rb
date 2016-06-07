#!/usr/bin/env ruby

require 'firewatir'

ff=FireWatir::Firefox.new
ff.goto("http://tcmtests.com")
ff.link(:text, "Free Board Tests").click


["Acupuncture Module Sample", "Asian Bodywork Module Sample", "Biomedicine Module Sample", "Foundations Module Sample", "Herbs Module Sample" ].each do |mdle|
	puts "\n\n... Starting module quiz for #{mdle} ..."
	ff.link(:text, mdle).click
	sleep(2)

	ff.attach(:title, "Sample Test")
	(1..Integer(ff.cell(:xpath, "//span[@id='klQStatQTOTAL']").text)).each do |a| 

	puts "=========== Question #{a} =========="

	question=ff.cell(:xpath, "//div[@id='klQuizQuestion']").text
	puts "Question: #{question}"

	answers=ff.cell(:xpath, "//div[@id='klQuizAnswers']").text
	puts "Answers: #{answers}" 

	ff.radio(:name, "klQuizAnswerRB").set
	ff.button(:id, "klQuizNextAction").click

	sleep(1)
	canswer=ff.cell(:xpath, "//label[@class='correct']").text
	puts "Correct answer: #{canswer}" 

	## If missing an explanation skip
	begin 
		explanation=ff.cell(:xpath, "//p[@class='explanation']").text
		puts "Explanation: #{explanation}" 
	rescue Watir::Exception::UnknownObjectException => e
		puts e.message
	end

	ff.button(:id, "klQuizNextAction").click
	sleep(3)

	end
	ff.attach(:title, "Acupuncture and Traditional Chinese Medicine exam self-study and testing from TCMtests.com")

end
puts "END"
