#encoding: utf-8
# require 'pp'

if ARGV.length < 3 
	puts "参数少于3个，应当是输入文件，中奖结果，分组数"
	return -1 
end

lottery_file = ARGV.shift
lottery_result = ARGV.shift
group_num = ARGV.shift.to_i

if not lottery_result.to_s.match(%r{^(\d{1,2}\s+){5}\d+})
	puts "输入中奖结果不正确"
	return -1
end	

red_result = lottery_result.to_s.match(%r{^(\d{1,2}\s+){5}\d+})[0].to_s.split
# pp red_result

if not File.file?(lottery_file)
	puts "输入的文件不存在"
	return -1 
end

if not (group_num.to_i > 0 and group_num.to_i < 7)
	puts "分组数值不正确，必须大于0小于7"
	return -1 
end

total_count = 0
group_result_match_count = 0
result_group_set = {}

open(lottery_file, 'r').each do |line|
	next if not line.to_s.match(%r{^(\d{1,2}\s+){5}\d+})
	line_red = line.to_s.match(%r{^(\d{1,2}\s+){5}\d+})[0].to_s.split
	
	if line_red
		total_count += 1
		i = 0
		str = ""
		
		line_red.each do |lr|
			
			red_result.each do |rr|
				if lr.to_i == rr.to_i
					i += 1
					str = str +" "+ rr.to_s
					break
				end
			end
			
			if i == group_num
				group_result_match_count += 1
				# puts line_red.to_s + "->" + str
				if result_group_set.has_key?(str)
					result_group_set[str] += 1
				else
					result_group_set[str] = 0
				end
				break
			end
			
		end
	end
	
end

def mean(x)
	sum=0
	x.each { |v| sum += v}
	sum/x.size
end
def variance(x)
	m = mean(x)
	sum = 0.0
	x.each { |v| sum += (v-m)**2 }
	sum/x.size
end
def sigma(x)
	Math.sqrt(variance(x))
end

file_name = group_num.to_s + 'r_ratio.txt'
open(file_name,'a') do |f|
	f.puts lottery_file.match(%r{\d+})[0].to_s
	80.times do f.print '-' end
	f.puts

	f.puts "total count: #{total_count}"
	f.puts "matchs: #{group_result_match_count}"
	f.puts "ratio: #{(group_result_match_count.to_f/total_count).to_s}"
	
	30.times do f.print '-' end
	f.puts
	v = result_group_set.values
	f.puts "mean: #{mean(v)}"
	f.puts "sigma: #{sigma(v)}"
	result_group_set.each do |k,v|
		f.puts "#{k} : #{v}"
	end
	f.puts	
end
