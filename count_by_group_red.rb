#encoding: utf-8

return -1 if ARGV.length < 3 

lottery_file = ARGV.shift
lottery_or_ratio = ARGV.shift
select_num = ARGV.shift

ratio = nil
lottery = nil

if lottery_or_ratio.split.length == 6
	lottery = lottery_or_ratio
elsif lottery_or_ratio.to_f.is_a?(Float)
	ratio = lottery_or_ratio.to_f
else
	puts "arg2 must be lottery or ratio"
	return -1
end

$group_result=[]
$order_set={}
$group_count={}

(1..33).each do |i|
	$group_count[i] = 1
end

if not (select_num.to_i > 0 and select_num.to_i <7)
	puts "select num must >0 and <7"
	return
end


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

def parse_order(order, select_num)
	two_set={}
	
	return if order.strip.length < 17
	
	red_ball = order.match(%r{([\d|\s]+)})[1].to_s.split
	blue_ball = order.match(%r{:([\d\s]+)})[1].split
	
	if select_num == 6
		a=red_ball.sort.join(" ")
		if $order_set.has_key?(a)
			$order_set[a] += 1
		else
			$order_set[a] = 1
		end	
		return
	end
	
	select_ary=[]
	tmp=[]
	num=select_num
	combine(red_ball, 6, select_num, tmp, num, select_ary)
	select_ary.each do |i|
		a=i.split
		b=a.sort.join(" ")
		
		if $order_set.has_key?(b)
			$order_set[b] += 1
		else
			$order_set[b] = 1
		end
	end
end

if lottery_file
	open(lottery_file,"r").each do |line|
		parse_order(line,select_num.to_i)
	end
end

max=1
min=999999
total_rows=$order_set.length
start_row=0
end_row=0

if ratio
	start_row = total_rows - (total_rows * ratio).to_i	
else
	ary_lottery=lottery.split
	tmp=[]
	l=ary_lottery.length
	m=select_num.to_i

	return if l != 6

	combine(ary_lottery,l,m,tmp,m,$group_result)

	$group_result.sort.each do |i|
		a=i.split
		
		key = a.sort.join(" ")
		max = $order_set[key] if $order_set[key] > max
		min = $order_set[key] if $order_set[key] < min
	end
end

puts start_row
i = 0
$order_set.sort_by{|k,v| v}.reverse.each do |k,v|
	if ratio
		i += 1
		if i > start_row
			k.split.each do |i|
				a = i.to_i
				if $group_count.has_key?(a)
					$group_count[a] = $group_count[a] + 1
				end
			end		
		end
	else
		if v.to_i < max and v.to_i > min
			k.split.each do |i|
				a = i.to_i
				if $group_count.has_key?(a)
					$group_count[a] = $group_count[a] + 1
				end
			end
		elsif v.to_i > max
			start_row += 1
		elsif v.to_i < min
			end_row += 1
		end
	end
end

file_name = ""
if ratio
	file_name = select_num+'r_'+ratio.to_s+'_'+lottery_file
else
	file_name = select_num+'r_'+lottery_file
end

open(file_name,'w') do |f|
	f.puts "Total rows: " + total_rows.to_s
	f.puts "Start row: " + start_row.to_s
	f.puts "End row(reverse): " + end_row.to_s
	f.puts "Count rows Ratio(%): " + ((total_rows-start_row).to_f*100/total_rows).to_s
	$group_count.sort_by{|k,v| v}.reverse.each do |k,v| f.puts k.to_s + " " + v.to_s end
end
