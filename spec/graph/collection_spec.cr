require "spec"
require "../src/graph/collection"

describe Graph::Collection do
  
  it "should let us add a call and retrieve it again" do
    
    call = Graph::Call.new do |c|
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
