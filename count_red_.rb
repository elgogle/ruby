#encoding: utf-8

file=ARGV.shift

red_set=[]
(0..5).each do |i|
	red_set[i] = {}
end

open(file,'r').each do |line|
	if line.match(%r{[\d|\s]+})
	
		red = line.match(%r{[\d|\s]+})[0].split
		
		if red.length == 6
			red.sort.each_with_index do |ball, index|
	
				if red_set[index].has_key?(ball)
					red_set[index][ball] += 1
				else
					red_set[index][ball] = 1
				end
			end
		end
		
	end
end


(0..5).each do |i|
	red_set[i] = red_set[i].sort_by{|k,v| v}.reverse
end



open('count_red_'+file, 'w') do |f|
	(0..32).each do |i|
		str = ""
		
		(0..5).each do|j|
		
			if red_set[j].length > i
				str += red_set[j][i][0].to_s + ":" + "%-6s"%red_set[j][i][1].to_s + " "*4
			else
				str += " "*9 + " "*4 
			end
			
		end
		
		if str.strip.length > 0
			puts str
			f.puts str
		end
		
	end
end

