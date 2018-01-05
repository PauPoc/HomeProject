require 'socket'
require 'uri'
require 'json'
require 'set'

server = TCPServer.new('localhost', 2345)

NUMBER_OF_WRONGS = 3

def getMinMax(request_uri)
  request_uri = request_uri[request_uri.index("?min=")+"?min=".length..-1]
  min = request_uri[0..request_uri.index("&")].to_i
  max = request_uri[request_uri.index("&max=")+"&max=".length..-1].to_i
  return min, max
end

def generateNumbers(min, max)
  answer = rand(min...max)
  val1 = rand(answer)
  val2 = answer - val1
  wrongs = Set.new
  wrongs << answer
  loop do
    wrongs << rand(min...max)
    break if wrongs.size > NUMBER_OF_WRONGS
  end
  wrongs.delete(answer)
  return val1, val2, answer, wrongs.to_a

end

def generateJSON(min, max)
  val1, val2, answer, wrongs = generateNumbers(min, max)
  result = {
      "question" => val1.to_s + " + " + val2.to_s + " = ?",
      "correctAnswer" => answer,
      "wrongAnswers" => wrongs
  }
  return result
end

loop do
  socket = server.accept
  request = socket.gets
  if ((request.include? "/add?min=") and (request.include? "&max="))
    min, max = getMinMax(request.split(" ")[1])
    if(min<0 || max > 1000000)
      socket.print("Values are out of range")
    elsif max - min < 3
      socket.print("Range is too small")
    else
      if min > max
        temp = max
        max = min
        min = temp
      end
      jsonOutput = generateJSON(min, max)
      socket.print jsonOutput
    end
  end
  socket.close
end
