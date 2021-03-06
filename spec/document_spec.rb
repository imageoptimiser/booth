require File.join(File.expand_path(File.dirname(__FILE__)),"spec_helper");

describe "Doc" do
  before(:each) do
    @d = Document.new({
      "_id" => "awesome",
      "foo" => "bar"
    })
  end
  it "should have an id" do
    @d.id.should == "awesome"
  end
  it "should have a rev" do
    @d.rev.should_not be_nil    
  end
  it "should have body" do
    @d.body["foo"].should == "bar"    
  end
  describe "updating it with a matching rev" do
    before(:each) do
      @r = @d.rev
      @d.update({
        "_id" => "awesome",
        "_rev" => @r,
        "foo" => "box"
      })
    end
    it "should get a new rev" do
      @d.rev.should_not == @r      
    end
    it "should update fields" do
      @d.body["foo"].should == "box"    
    end
  end
  describe "deleting a doc" do
    before(:each) do
      @r = @d.rev
      @d.update({
        "_id" => "awesome",
        "_rev" => @r,
        "_deleted" => true
      })
    end
    it "should be deleted" do
      @d.deleted.should be_true
    end
    it "should update without a rev" do
      @d.update({
        "_id" => "awesome",
        "totally_new" => "yeah"
      })
      @d.jh["totally_new"].should == "yeah"
    end
  end
  describe "updating it with a conflict" do
    before(:each) do
      @r = @d.rev
      @d.update({
        "_id" => "awesome",
        "_rev" => "@r",
        "foo" => "conflict"
      },{
        :all_or_nothing => "true"
      })
      @cfts = @d.jh(:conflicts => "true")["_conflicts"]
    end
    it "should have conflict_revs" do
      @cfts.length.should == 1
    end
    it "should load conflict revs" do
      @d.jh({:rev => @cfts[0]})["_rev"].should == @cfts[0]
      @d.jh["_rev"].should_not == @cfts[0]
    end
  end
  it "should have no conflicts" do
    @d.conflicts.should == []
  end
end
