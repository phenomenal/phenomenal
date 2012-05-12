# Define the test classes
class TestString < String
end

class TestString2 < String
end

class TestClass < String
  @klass_inst_var = 2
  @@klass_var = 1
  attr_accessor :value
  def initialize(str)
    @value=str
  end
  def to_s
    value.to_s
  end
  def eql?(str)
    str.eql?(value.to_s)
  end

  def self.klass_var_access
    @@klass_var
  end
  
  def instance_klass_var_access
    @@klass_var
  end

  def self.klass_inst_var_access
    @klass_inst_var
  end

  def print(arg)
    "0 -> ARG: #{arg.to_s}"
  end
end

class Call
  attr_accessor :from
  def initialize(a_string)
    @from=a_string
  end
  def to_s
  	"from" + from
	end
end

class Phone
  attr_accessor :incoming_calls, :ongoing_calls, :terminated_calls,
                :missed_calls, :active_call

  def initialize
    @incoming_calls = Array.new
	  @ongoing_calls = Array.new
	  @terminated_calls =Array.new
	  @missed_calls = Array.new
	  @active_call = nil
  end

  def advertise(a_call)
    "ringtone"
  end

  def answer
  	nextCall = incoming_calls.first
  	if nextCall.nil?
  	  raise ("No incoming calls to answer.")
	  end
	  answer_call(nextCall)
  end

  def answer_call(a_call)
    incoming_calls.delete(a_call) do
      raise ("Only incoming calls can be answered.")
    end
    suspend
    ongoingCalls.push(a_call)
    resume(a_call)
  end

  def hang_up
    if active_call.nil?
      raise ("No active call to hang up")
    end
    hang_up_call(active_call)
  end

  def hang_up_call(a_call)
    ongoing_calls.delete(a_call) { raise ("Only ongoing calls can be hung up.")}
    if active_call == a_call
      suspend
    end
    terminated_calls.push(a_call)
  end

  def miss(a_call)
    incoming_calls.delete(a_call) {raise ("Only incoming calls can be missed.")}
    missed_calls.push(a_call)
  end

  def receive(a_call)
    incoming_calls.push(a_call)
    advertise(a_call)
  end

  def resume(a_call)
    if !ongoing_calls.include?(a_call)
      raise ("Only ongoing calls can be resumed.")
    end
    active_call(a_call)
  end

  def suspend
    active_call(nil)
  end
end

