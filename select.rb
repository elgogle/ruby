#encoding: utf-8

file=ARGV.shift

red_set={}
blue_set={}
	
open(file,'r').each do |line|
	if line.match(%r{\:(\d+)})
		blue = line.match(%r{\:(\d+)})[1].to_s
		if blue_set.has_key?(blue)
			blue_set[blue] +=1
		else
			blue_set[blue] = 1
		end
	end
end

blue_set.sort_by{|k,v| v}.reverse.each do |key,value|
	puts key.to_s + ' : ' + value.to_s
end