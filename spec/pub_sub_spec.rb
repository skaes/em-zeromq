require File.join(File.dirname(__FILE__), %w[spec_helper])

describe EventMachine::ZeroMQ do
  class EMTestSubHandler
    attr_reader :received
    def initialize
      @received = []
    end
    def on_readable(socket, messages)
      @received += messages
    end
  end

  it "Should instantiate a connection given valid opts" do
    sub_conn = nil
    run_reactor(1) do
      sub_conn = SPEC_CTX.bind(ZMQ::PUB, rand_addr, EMTestSubHandler.new)
    end
    sub_conn.should be_a(EventMachine::ZeroMQ::Connection)
  end

  describe "sending/receiving a single message via PUB/SUB" do
    before(:all) do
      results = {}
      @test_message = test_message = "TMsg#{rand(999)}"
      
      run_reactor(0.5) do
        results[:sub_hndlr] = pull_hndlr = EMTestSubHandler.new
        sub_conn  = SPEC_CTX.bind(ZMQ::SUB, rand_addr, pull_hndlr)
        sub_conn.subscribe('')
        
        pub_conn  = SPEC_CTX.connect(ZMQ::PUB, sub_conn.address, EMTestSubHandler.new)
        
        pub_conn.socket.send_string test_message, ZMQ::NOBLOCK
        
        EM::Timer.new(0.1) { results[:specs_ran] = true }
      end
      
      @results = results
    end
  
    it "should run completely" do
      @results[:specs_ran].should be_true
    end
    
    it "should receive one message" do
      @results[:sub_hndlr].received.length.should == 1
    end

    if defined?(ZMQ::Message)
      it "should receive the message as a ZMQ::Message" do
        @results[:sub_hndlr].received.first.should be_a(ZMQ::Message)
      end
    end
    
    it "should receive the message intact" do
      @results[:sub_hndlr].received.first.copy_out_string.should == @test_message
    end
  end
end
