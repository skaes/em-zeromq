require File.join(File.dirname(__FILE__), %w[spec_helper])

describe EventMachine::ZeroMQ do
  class EMTestPullHandler
    attr_reader :received
    def initialize
      @received = []
    end
    def on_readable(socket, messages)
      @received += messages
    end
  end

  it "Should instantiate a connection given valid opts" do
    pull_conn = nil
    run_reactor do
      pull_conn = SPEC_CTX.bind(ZMQ::PULL, rand_addr, EMTestPullHandler.new)
    end
    pull_conn.should be_a(EventMachine::ZeroMQ::Connection)
  end

  describe "sending/receiving a single message via PUB/SUB" do
    before(:all) do
      results = {}
      @test_message = test_message = "TMsg#{rand(999)}"
      
      run_reactor(0.5) do
        results[:pull_hndlr] = pull_hndlr = EMTestPullHandler.new
        pull_conn = SPEC_CTX.bind(ZMQ::PULL, rand_addr, pull_hndlr)
        push_conn  = SPEC_CTX.connect(ZMQ::PUSH, pull_conn.address)
        
        push_conn.socket.send_string test_message, ZMQ::NOBLOCK
        
        EM::Timer.new(0.1) { results[:specs_ran] = true }
      end
      
      @results = results
    end

    it "should run completely" do
      @results[:specs_ran].should be_true
    end
    
    it "should receive the message intact" do
      @results[:pull_hndlr].received.should_not be_empty
      @results[:pull_hndlr].received.first.should be_a(ZMQ::Message) if defined?(ZMQ::Message)
      @results[:pull_hndlr].received.first.copy_out_string.should == @test_message
    end
  end
end
