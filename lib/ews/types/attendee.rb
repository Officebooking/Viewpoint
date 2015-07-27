=begin
  This file is part of Viewpoint; the Ruby library for Microsoft Exchange Web Services.

  Copyright © 2011 Dan Wanek <dan.wanek@gmail.com>

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
=end

module Viewpoint::EWS::Types

  class Attendee < MailboxUser

    attr_accessor :response_type, :last_response_time

    def initialize(ews, user_hash)
      mbox_user = nil
      user_hash[:attendee][:elems].each do |a|
        if a[:mailbox]
          mbox_user = a[:mailbox][:elems]
        elsif a[:response_type]
          @response_type = a[:response_type][:text]
        elsif a[:last_response_time]
          @last_response_time = a[:last_response_time][:text]
        end
      end
      super(ews, mbox_user)
    end

  end # Attendee

end # Viewpoint::EWS::Types
