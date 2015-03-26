#encoding: utf-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'

$home_page_url = 'http://www.aicai.com/hemai/?&lotteryID=101&groupSqlBuildType=TOP&isFull=1&encryptBoolean=true&hmActionPageUrl=/hemai/hemailottery!hemailPlan.jhtml&current_page=1&showPageSize=50'
$detail_link = []
$united_order_detail_link = []
$united_list_all_page_link = []

$issueNo = ARGV.shift
puts $issueNo

def get_html(url)
	i = 0
	begin
		i += 1
		txt = open(url)
		return txt.read
	rescue
		puts i.to_s + ' times try open(' + url + ')'
		retry
	end
end

def get_detail_link(url)
    content = get_html(url)

    content.scan(%r{\<a href\=\"/(hemai-[\w|\d]+\.html)\" target\=\"\_blank\"\>详情\<\/a\>}).each do |item|
        $detail_link << 'http://www.aicai.com/'+item[0].to_s
        # puts item
    end
end

def get_united_order_detail_link(url)
    content = get_html(url)

    planNo = content.match(%r{plan_planNo \= \'([\w|\d]+)\'})[1].to_s if content.match(%r{plan_planNo \= \'([\w|\d]+)\'})
	
	$united_order_detail_link << "http://www.aicai.com/hemai/hemaidetail!queryPlanDetailContent.jhtml?planNo=#{planNo}&game=FC_SSQ&issueNo=#{$issueNo}&selectType=MANUAL&joinEnd=false&planPublicType=LAUNCH_PLAN"
	# puts "planNo:#{planNo}\tissueNo:#{issueNo}"
end

def get_order_detail(url, out_file)
    content = get_html(url)

	str = ""
    content.scan(%r{\<td class\=\"left_text\"\>([\d|,|\s]+)\&nbsp;\|&nbsp;([\d|,|\s]*)}).each do |item|
        str = item[0].to_s.gsub(/,/,' ') + ":" + item[1].to_s.gsub(/,/,' ')
    end

    content.scan(%r{\<td class\=\"left_text\"\>胆\&nbsp;([\d|,|\s]+)\&nbsp;拖\&nbsp;([\d|,|\s]+)\&nbsp;\|\&nbsp;([\d|,|\s]*)}).each do |item|
        str = '(' + item[0].to_s.gsub(/,/,' ')+')'+item[1].to_s.gsub(/,/,' ') + ":" + item[2].to_s.gsub(/,/,' ')
    end
	
	if str.length > 0
		puts str
		open(out_file,'a') do |f|
			f.puts str
		end
	end
end

def get_united_list_link(first_url)
    first_base_url='http://www.aicai.com/hemai/?&lotteryID=101&groupSqlBuildType=TOP&isFull=1&encryptBoolean=true&hmActionPageUrl=/hemai/hemailottery!hemailPlan.jhtml&current_page='
    last_base_url='&showPageSize=50'	
	
	content = get_html(first_url)
	max_item = content.match(%r{共(\d+)条})
	if max_item
		
		page = max_item[1].to_f/50
		if page > 1
			if page.to_f > page.to_i
				page = page.to_i + 1
			else
				page = page.to_i
			end			
		end
		
	end
	
	(1..page).each do |p|
		puts p.to_s
		$united_list_all_page_link << first_base_url + p.to_s + last_base_url
	end
end

# a = 'http://www.aicai.com/hemai/hemaidetail!queryPlanDetailContent.jhtml?planNo=H121125154517997&game=FC_SSQ&issueNo=2012140&selectType=MANUAL&joinEnd=false&planPublicType=LAUNCH_PLAN'
# get_order_detail(a,1)
output_file = $issueNo + '_aicai.txt'
open(output_file,'w')

get_united_list_link($home_page_url)

threads = []
$united_list_all_page_link.each do |page_link|
	puts page_link
	
	
	threads << Thread.new(page_link) do |my_page|
		get_detail_link(my_page)
		while $detail_link.length > 0 do
			link_1 = $detail_link.pop
			
			get_united_order_detail_link(link_1)
			
			while $united_order_detail_link.length > 0 do
				link_2 = $united_order_detail_link.pop
				get_order_detail(link_2,output_file)
			end
		end
	end
	
end
threads.each { |aThread|  aThread.join }
