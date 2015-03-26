#encoding: utf-8
# require 'pp'

if ARGV.length < 3 
	puts "参数少于3个，应当是输入文件，分组数, 比值"
	return -1 
end


lottery_file = ARGV.shift
select_num = ARGV.shift.to_i
ratio = ARGV.shift.to_f

if not File.file?(lottery_file)
	puts "输入的文件不存在"
	return -1 
end

if not (select_num.to_i > 2 and select_num.to_i < 6)
	puts "分组数值不正确，必须大于2小于6"
	return -1 
end

$result_hash = {}

def combine(a, n, m, b, cm, out_pailie)
	n.downto(m) do |i|
		b[m-1] = i-1
		if m>1
			combine(a,i-1,m-1,b,cm,out_pailie)
		else
			s = ""
			(cm-1).downto(0) do |j|
				s += a[b[j]].to_s + " "
			end
			out_pailie << s.strip
		end
	end
end

red_ball = (1..33).to_a
select_ary = []
tmp = []
num = select_num
combine(red_ball, 33, select_num, tmp, num, select_ary)

# puts red_ball
select_hash = {}
# puts select_ary.size
select_ary.each do |i|
	select_hash[i.split.sort{|a,b| a.to_i <=> b.to_i}.join(" ")] = 0
end

# pp select_hash

line_count = 0
open(lottery_file,"r").each do |line|
	if line.to_s.match(%r{^(\d{1,2}\s+){5}\d+})
		line_red = line.to_s.match(%r{^(\d{1,2}\s+){5}\d+})[0].to_s.split
		if line_red
			line_count += 1
			line_select_ary = []
			tmp = []
			num = select_num
			combine(line_red, 6, select_num, tmp, num, line_select_ary)
			
			# puts line_select_ary.size
			line_select_ary.each do |lsa|
				
				a = []
				# puts "lsa#{lsa}"
				lsa.split.sort{|a,b| a.to_i <=> b.to_i}.each do |i|
					a << i.to_i
				end
				str = a.join(" ")
				
				# puts str
				select_hash[str] += 1 if select_hash.has_key?(str)
				# pp select_hash[str]
			end
			
		end
	end
end
# puts line_count
# select_hash.sort_by{|k,v| v}.each do |k,v|
	# puts "#{k}:#{v}"
# end
# return

total_count = 0
select_hash.values.each do |i|
	total_count += i
end

multip = 400
case select_num
when 4
	multip = 225
when 5
	multip = 36
end

# pp	select_hash

select_hash.sort_by{|k,v| v}.each do |k,v|
	# puts v
	if v < total_count/multip*ratio*1.5 and v > total_count/multip*ratio*0.5
		k.split.each do |r|
			if r.to_s.match(%r{\d+})
				if $result_hash.has_key?(r.to_s)
					$result_hash[r.to_s] += 1
				else
					$result_hash[r.to_s] = 1
				end
			end
		end
	end
end

# pp $result_hash
# return
file_name = select_num.to_s + 'r_' + ratio.to_s + '.txt'


open(file_name,'a') do |f|
	f.puts lottery_file.match(%r{\d+})[0].to_s
	f.puts "total count: #{total_count}"
	80.times do f.print '-' end
	f.puts	

	$result_hash.sort_by{|k,v| v}.reverse.each do |k,v|
		f.puts "#{k} #{v}"
	end
	f.puts
end

