#encoding: utf-8
require 'mysql'

issue=ARGV.shift

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

if issue
	begin
		dbh = Mysql.real_connect('localhost', 'root', '', 'Lottery')
		
		res=dbh.query("select * from ssq_master where issue=#{issue}")
		res.each do |row|
			red_ball = row[1,6]
						
			#select two_set
			two_ary=[]
			tmp=[]
			two=2
			combine(red_ball, 6, 2, tmp, two, two_ary)
			two_ary.each do |i|
				a=i.split
				b=a.sort

				
				r=dbh.query("select * from ssq_r2 where issue=#{issue} and r1=#{b[0].to_i} and r2=#{b[1].to_i}")

				if r.num_rows > 0
					dbh.query("update ssq_r2 set qty=qty+1 where issue=#{issue} and r1=#{b[0].to_i} and r2=#{b[1].to_i}")
				else
					dbh.query("insert into ssq_r2 values(#{issue}, #{b[0].to_i}, #{b[1].to_i}, 1)")
				end
			end			
		end
		res.free
	ensure
		dbh.close
	end
end