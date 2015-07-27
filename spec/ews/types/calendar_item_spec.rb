require 'spec_helper'

describe Viewpoint::EWS::Types::CalendarItem do

  describe "#duration" do
    it "returns the duration in seconds" do
      allow_any_instance_of(described_class).to receive(:simplify!)
      calitem = described_class.new(nil, nil)
      allow(calitem).to receive(:duration).and_return("PT0H30M0S")
      expect(calitem.duration_in_seconds).to eql(1800)
    end
  end

  describe "#build_attendees_users" do

    let(:users_data) { [ # this is the way the data comes to #build_attendees_users
      {:attendee=>{:elems=>[
        {:mailbox=>{:elems=>[
          {:name=>{:text=>"user2"}},
          {:email_address=>{:text=>"user2@web.eu"}},
          {:routing_type=>{:text=>"SMTP"}},
          {:mailbox_type=>{:text=>"Mailbox"}}
        ]}},
        {:response_type=>{:text=>"Tentative"}},
        {:last_response_time=>{:text=>"2015-07-14T08:45:28Z"}}]}},
      {:attendee=>{:elems=>[
        {:mailbox=>{:elems=>[
          {:name=>{:text=>"user3"}},
          {:email_address=>{:text=>"user3@web.eu"}},
          {:routing_type=>{:text=>"SMTP"}},
          {:mailbox_type=>{:text=>"Mailbox"}}]}},
        {:response_type=>{:text=>"Unknown"}}]}}
    ] }

    it "should return an empty array if there are no attendees" do
      calitem = described_class.new({}, {})
      calitem.send(:build_attendees_users, [{ attendee: { elems: [] } }]).should == []
      calitem.send(:build_attendees_users, []).should == []
    end

    it "should return attendees which support response and response time" do
      calitem = described_class.new({}, {})
      attendees = calitem.send(:build_attendees_users, users_data)

      attendee1 = attendees[0]
      attendee1.response_type.should == "Tentative"
      attendee1.last_response_time.should == "2015-07-14T08:45:28Z"

      attendee2 = attendees[1]
      attendee2.response_type.should == "Unknown"
      attendee2.last_response_time.should be_nil
    end

  end

end
