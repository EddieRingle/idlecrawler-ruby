require "hpricot"
require "net/http"

class Spider
    def initialize(url)
        @keywords = Hash.new(0)
        @url = URI.parse(url)
        @common = [
        'the','be','to','of','and','a','in','that','have','i','it','for','not',
        'on','with','as','you','do','at','this','but','by','from','they',
        'say','or','an','will','all','would','there','their','what','so','up',
        'out','if','get','which','when','can','like','no','just','take','into',
        'some','could','them','other','than','then','now','only','come','its',
        'also','over','back','after','use','our','well','way','even','want',
        'because','these','give','us','most','|','\\','/','is'
        ]
    end
    def crawl()
        http = Net::HTTP.new(@url.host, @url.port)
        path = @url.path != "" ? @url.path : '/'
        result = http.get(path)
        doc = Hpricot(result.body)
        content = doc.search('body')
        if content.empty?
            content = doc.search('BODY')
            if content.empty?
                throw "Invalid HTML"
            end
        end
        (content/"script").remove
        (content/"SCRIPT").remove
        (content/"style").remove
        (content/"STYLE").remove
        content.inner_text.split(' ').each do |v|
            @keywords[v] += 1 if @common.rindex(v.downcase) == nil
        end
        @keywords = @keywords.sort {|k,v| -1*(k[1] <=> v[1])}
        @keywords.each do |k,v|
            puts "#{k} appears #{v} times."
        end
    end
end

s = Spider.new(ARGV[0])
s.crawl
