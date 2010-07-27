#############################################################################
# Copyright © 2010 Dan Wanek <dan.wanek@gmail.com>
#
#
# This file is part of Viewpoint.
# 
# Viewpoint is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
# 
# Viewpoint is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with Viewpoint.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
require 'builders/ews_build_helpers.rb'
module Viewpoint
  module EWS
    module SOAP
      class EwsBuilder
        include EwsBuildHelpers

        def initialize(node, opts, &block)
          @node, @opts = node, opts
          instance_eval(&block) if block_given?
        end

        def resolve_names!(name, full_contact_data, opts)
          @node.set_attr('ReturnFullContactData',full_contact_data)
          @node.add("#{NS_EWS_MESSAGES}:UnresolvedEntry",name)
        end


        def find_folder!(parent_folder_ids, traversal, folder_shape, opts)
          @node.set_attr('Traversal', traversal)
          folder_shape!(@node, folder_shape)
          parent_folder_ids!(@node, parent_folder_ids)
        end


        def find_item!(parent_folder_ids, traversal, item_shape)
          @node.set_attr('Traversal', traversal)
          item_shape!(@node, item_shape)
          parent_folder_ids!(@node, parent_folder_ids)
        end


        # @todo refactor so DistinguishedFolderId and FolderId have their own builders
        def get_folder!(folder_ids, folder_shape)
          folder_shape!(@node, folder_shape)
          folder_ids!(@node, folder_ids)
        end


        # @see ExchangeWebService#subscribe
        def pull_subscription_request!(folder_ids, event_types, timeout)
          @node.add("#{NS_EWS_MESSAGES}:PullSubscriptionRequest") do |ps|
            folder_ids!(ps, folder_ids, "#{NS_EWS_TYPES}:FolderIds")
            event_types!(ps, event_types)
            ps.add("#{NS_EWS_TYPES}:Timeout", timeout)
          end
        end


        # @see ExchangeWebService#get_events
        def get_events!(subscription_id, watermark)
          subscription_id!(@node, subscription_id)
          watermark!(@node, watermark)
        end


        def get_item!(item_ids, item_shape)
          item_shape!(@node, item_shape)
          item_ids!(@node, item_ids)
        end


        # @param [String] type The type of items in the items array message/calendar
        # @todo Fix max_changes_returned to be more flexible
        def create_item!(folder_id, items, message_disposition, send_invites, type)
          @node.set_attr('MessageDisposition', message_disposition) if message_disposition
          @node.set_attr('SendMeetingInvitations', send_invites) if send_invites

          saved_item_folder_id!(@node, folder_id)
          items!(@node, items, type)
        end

        def sync_folder_items!(folder_id, item_shape, opts)
          item_shape!(@node, item_shape)
          @node.add("#{NS_EWS_MESSAGES}:SyncFolderId") do |sfid|
            folder_id!(sfid, folder_id)
          end
          @node.add("#{NS_EWS_MESSAGES}:MaxChangesReturned", 100)
        end


      end # EwsBuilder
    end # SOAP
  end # EWS
end # Viewpoint
