#
# Author:: Christopher Peplin (<peplin@bueda.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rubygems'
require 'aws/s3'

class Chef::Resource::RemoteFile
  def access_key_id(args=nil)
    set_or_return(
      :access_key_id,
      args,
      :kind_of => String
    )
  end
    
  def secret_access_key(args=nil)
    set_or_return(
      :secret_access_key,
      args,
      :kind_of => String
    )
  end
end 


class Chef::Provider::RemoteFile
  def fetch_from_uri(source)
    begin
      uri = URI.parse(source)
      if uri.absolute
        if uri.scheme == "s3"
          AWS::S3::Base.establish_connection!(
              :access_key_id     => @new_resource.access_key_id,
              :secret_access_key => @new_resource.secret_access_key
          )
          name = uri.path[1..-1]
          bucket = uri.host
          obj = AWS::S3::S3Object.find name, bucket
          Chef::Log.debug("Downloading #{name} from S3 bucket #{bucket}")
          file = Tempfile.new("chef-s3-file")
          file.write obj.value
          begin
            yield file
          ensure
            file.close
          end
        end
      end
    rescue URI::InvalidURIError
      nil
    end
  end
end
