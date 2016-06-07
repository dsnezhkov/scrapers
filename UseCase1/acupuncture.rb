#!/usr/bin/env ruby 

require 'firewatir'
require 'date'

ff=FireWatir::Firefox.new
ff.goto("https://www.site.com/login/")
ff.text_field(:name,"Username").set("guest")
ff.text_field(:name,"Password").set("cheerful")
begin 
	ff.button(:src, /login/).click
	ff.button(:src, /continue/).click
	ff.goto("http://www.site.com/members/mode/boards/biomed")
rescue Watir::Exception::UnknownObjectException => e
	$stderr.puts "Error: " + e.to_s
	exit(1)
end

quizzes = { 
'Reflexes' => 'Reflexes',
'Range of Motion' => 'Range of Motion',
'Musculoskeletal Examination A' => 'Musculoskeletal Examination A',
'Musculoskeletal Examination B' => 'Musculoskeletal Examination B',
'Musculoskeletal Examination C' => 'Musculoskeletal Examination C',
'Musculoskeletal Examination D' => 'Musculoskeletal Examination D',
'Musculoskeletal Examination E' => 'Musculoskeletal Examination E',
'Musculoskeletal Examination F' => 'Musculoskeletal Examination F',
'Blood Case Studies' => 'Blood Case Studies',
'Cardiovascular Case Studies' => 'Cardiovascular Case Studies',
'Respiratory Case Studies' => 'Respiratory Case Studies',
'Gastrointestinal Case Studies' => 'Gastrointestinal Case Studies',
'Genitourinary Case Studies' => 'Genitourinary Case Studies',
'Endocrine Case Studies' => 'Endocrine Case Studies',
'Neurological Case Studies' => 'Neurological Case Studies',
'Musculoskeletal Case Studies' => 'Musculoskeletal Case Studies',
'Reproductive Case Studies' => 'Reproductive Case Studies',
'Infectuous Case Studies' => 'Infectuous Case Studies',
'Cases Studies A' => 'Case Studies B',
'Case Studies B' => 'Case Studies B',
'Case Studies C' => 'Case Studies C',
'Case Studies D' => 'Case Studies D',
'Case Studies E' => 'Case Studies E',
'Case Studies F' => 'Case Studies F',
'Case Studies G' => 'Case Studies G',
'Case Studies H' => 'Case Studies H'
} 


quizzes.each do |key,value|

	curtime=DateTime.now(); 
	puts "\n#{curtime.strftime("%m-%h-%y_%H:%M:%S")} Starting module quiz for #{key} ..."
	ff.link(:text, /#{key}/).click
	sleep(6)

	ff.attach(:title, /#{value}/)


	path=key.gsub(/ +/, '')

	begin
		file   = File.open(path, File::WRONLY|File::TRUNC|File::CREAT, 0666) 
	rescue Exception => e
		$stderr.puts e
		next
	end

	file.sync=true

	(1..Integer(ff.cell(:xpath, "//span[@id='klQStatQTOTAL']").text)).each do |a| 

		file.puts "=========== Question #{a} =========="

		question=ff.cell(:xpath, "//div[@id='klQuizQuestion']").text
		file.puts "Question: #{question}"

		answers=ff.cell(:xpath, "//div[@id='klQuizAnswers']").text
		file.puts "Possible Answers: #{answers}" 

		sleep(5)
		begin 
			ff.radio(:name, "klQuizAnswerRB").set
		rescue Watir::Exception::UnknownObjectException => e
			ff.checkbox(:name, "klQuizAnswerRB").set
		end
		ff.button(:id, "klQuizNextAction").click

		sleep(1)
		canswer=ff.cell(:xpath, "//label[@class='correct']").text
		file.puts "Correct answer: #{canswer}" 

		## If missing an explanation skip
		begin 
			explanation=ff.cell(:xpath, "//p[@class='explanation']").text
			file.puts "Explanation: #{explanation}" 
		rescue Watir::Exception::UnknownObjectException => e
			file.puts "Explanation: Not Available" 
		end

		ff.button(:id, "klQuizNextAction").click
		sleep(1)

	end 

	file.close

	ff.attach(:title, "TITLE OF SITE")

end
puts "END"
