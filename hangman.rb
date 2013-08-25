
require "net/http"
require "json"
f = open("hangmanresults.txt","w")
class RequestText
	def initialize(body)
		@body = body
	end
	def changebody(body)
		@body = body
	end
	def getmessage
		uri = URI.parse("http://strikingly-interview-test.herokuapp.com/guess/process")

		http = Net::HTTP.new(uri.host,uri.port)

		request = Net::HTTP::Post.new(uri.path)
		request.add_field('Content-Type','application/json')
		request.set_form_data (@body)

		response = 	http.request(request)
		return response.body
	end
end
list0 = IO.readlines("mywords0.txt")
list0.each{
	|x|
	x.strip!.upcase!
}
list1 = IO.readlines("mywords1.txt")
list1.each{
	|x|
	x.strip!.upcase!
}
list2 = IO.readlines("mywords2.txt")
list2.each{
	|x|
	x.strip!.upcase!
}
list3 = IO.readlines("mywords3.txt")
list3.each{
	|x|
	x.strip!.upcase!
}
list4 = IO.readlines("mywords4.txt")
list4.each{
	|x|
	x.strip!.upcase!
}
#guess algorithm
def GenerateGuess(word,used)

	def compare(x,y,used)
		if x.length != y.length 
			return false
		else 
			for i in 0...x.length
				if (x[i] != y[i] && y[i] !='*')
					return false
				end
				if (y[i] == "*" && (used.include? x[i]))
					return false
				end
			end
		end
	end


	timescount = Hash.new(0)#count each letter
	for ch in 'A'..'Z' 
		timescount[ch] = 0
	end
	$matchwords = $matchwords.select { |x| compare(x,word,used) }
	$matchwords.each {
		|x|
			for i in 0...x.length
				ch = x[i..i].upcase
			
				unless (word.include? ch) || (used.include? ch)
					timescount[ch] += 1

				end
			end
	}
	ans = 0
	for ch in 'A'..'Z'
		if timescount[ch] > ans
			ans = timescount[ch]
			k = ch
		end
	end
	if ans!=0
		return k
	else 
		return "none"
	end
end
#Initite Game
#=begin
initiate_text = RequestText.new({
	"action" => "initiateGame",
	"userId" => "nanshu.wang@gmail.com"
	})

message = JSON.parse(initiate_text.getmessage)
f.puts secret = message["secret"]
#=end
#secret = '4G7I1JILR0LCV7VI1DXQV3T2JYKTKE'
	get_a_word_text = RequestText.new({
	    "userId"=>"nanshu.wang@gmail.com",
	    "action"=>"nextWord",
	    "secret"=>secret
	    })
	guess_text = RequestText.new({
		    "action"=>"guessWord",
		    "guess"=>"",
		    "userId"=>"nanshu.wang@gmail.com",
		    "secret"=>secret
		})
#BeginGame
wordTried = 0
while wordTried <80
	#getnextword

	message = JSON.parse(get_a_word_text.getmessage)
	word = message["word"]
	allowedGuess = message["data"]["numberOfGuessAllowedForThisWord"]
	wordTried = message["data"]["numberOfWordsTried"]
	used = ""
	#make a guess
	if wordTried <=20 
		$matchwords = list1
	elsif wordTried <=40
		$matchwords = list2
	elsif wordTried <=60
		$matchwords = list3
	else
		$matchwords = list4
	end
	if word.length ==3 
		$matchwords = list0
	end
	while (word.include? "*") && (allowedGuess > 0)
		guess = GenerateGuess(word,used)
		break if guess=="none"
		used <<guess
		guess_text.changebody({
		    "action"=>"guessWord",
		    "guess"=>guess,
		    "userId"=>"nanshu.wang@gmail.com",
		    "secret"=>secret
		})
		message = JSON.parse(guess_text.getmessage)
		word = message["word"]
		allowedGuess = message["data"]["numberOfGuessAllowedForThisWord"]
		
		
	end
	f.puts $matchwords.size
	f.puts used
	f.puts word
	f.puts allowedGuess
	f.puts wordTried
	f.puts '-------'
	puts $matchwords.size
	puts used
	puts word
	puts allowedGuess
	puts wordTried
	puts '-------'

end

#getTestResults
getResults = RequestText.new({
    "action"=>"getTestResults",
    "userId"=>"nanshu.wang@gmail.com",
    "secret"=>secret
})
f.puts getResults.getmessage