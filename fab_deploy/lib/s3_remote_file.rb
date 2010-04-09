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

require "aws/s3"

module S3RemoteFile
  def get_from_uri(source)
    begin
      uri = URI.parse(source)
      if uri.absolute
        if uri.scheme == "s3"
          AWS::S3::Base.establish_connection!(
              :access_key_id     => uri.user,
              :secret_access_key => uri.password
          )
          name = u.path[1..-1]
          bucket = u.host
          obj = AWS::S3::S3Object.find name, bucket
          Chef::Log.debug("Downloading #{name} from S3 bucket #{bucket}")
          Tempfile.new("chef-s3-file").write obj.value
        else
          r = Chef::REST.new(source, nil, nil)
          Chef::Log.debug("Downloading from absolute URI: #{source}")
          r.get_rest(source, true).open
        end
      end
    rescue URI::InvalidURIError
      nil
    end
  end
end
