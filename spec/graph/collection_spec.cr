require "spec"
require "../../src/graph/collection"
require "../../src/brain/dummy_handler"
require "../../src/transport/debug"

describe Graph::Collection do
  it "should let us add a call and retrieve it again" do
    transport = Transport::Debug.new

    call = Graph::Call.new do |c|
      c.handler = Brain::DummyHandler.new(transport)
      c.to = "someone@akjsdf.org"
      c.call_id = "callno93"
      c.server_userfrag = "ourcrazyname"
      c.client_userfrag = "krispykreme"
      c.server_password = "servypass"
      c.client_password = "crazypass"
    end

    added_call = Graph::Collection.add(call)
    call = Graph::Collection.find_by_username("ourcrazyname:krispykreme")
    call.should eq(added_call)
  end
end
