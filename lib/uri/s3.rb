# frozen_string_literal: true

require "uri"
require "aws-sdk-s3"

module URI
  class S3 < Generic
    alias bucket_name host

    def s3_bucket(**options)
      @s3_bucket ||= begin
                       options[:region] = s3_region unless options.key?(:region)
                       s3_resource(**options).bucket(bucket_name)
                     end
    end

    def s3_region
      @s3_region ||= begin
                       region = s3_client.get_bucket_location(bucket: bucket_name).location_constraint
                       if region.empty?
                         "us-east-1"
                       else
                         region
                       end
                     end
    end

    def s3_object(**options)
      @s3_object ||= s3_bucket(**options).object(s3_key)
    end

    def s3_client(**options)
      Aws::S3::Client.new(options)
    end

    def index(**options)
      params = { bucket: bucket_name, prefix: key, max_keys: 1000 }
      Enumerator.new do |yielder|
        client = s3_client(**options)
        loop do
          resp = client.list_objects_v2(params)
          resp.contents.each {|entry| yielder << entry }
          break unless resp.is_truncated

          params[:continuation_token] = resp.next_continuation_token
        end
      end
    end

    def fetch(**options)
      s3_object(**options).get.body
    end

    def get
      s3_object.get.body.read
    end

    def put(body:, **options)
      s3_object.put(body:, **options)
    end

    def download_file(filename)
      s3_object.download_file(filename)
    end

    def upload_file(file, **options)
      s3_object.upload_file(file, options)
    end

    def to_http(expires_in: nil, **options)
      if expires_in.nil?
        URI(s3_object.public_url)
      else
        URI(s3_object.presigned_url(:get, expires_in:, **options))
      end
    end

    def upload_url(public_read: false, **options)
      if public_read
        URI(s3_object.presigned_url(:put, acl: "public-read", **options))
      else
        URI(s3_object.presigned_url(:put, **options))
      end
    end

    def exists?
      s3_object.exists?
    end

    def content_type
      s3_object.content_type
    end

    def content_type=(type)
      s3_object.copy_from(s3_object, content_type: type, metadata_directive: "REPLACE")
    end

    def last_modified
      s3_object.last_modified
    end

    def metadata
      s3_object.metadata
    end

    def permissions=(permission)
      s3_object.acl.put(acl: permission.to_s.tr("_", "-"))
    end

    def public?
      s3_object.acl.grants.any? do |grant|
        grant.grantee.uri == "http://acs.amazonaws.com/groups/global/AllUsers" && grant.permission == "READ"
      end
    end

    def content_length
      s3_object.content_length
    end

    def destroy
      s3_object.delete
    end

    def key
      path[1..]
    end

    class << self
      def build_s3(bucket_name, key = "/")
        path = key.split("/").map {|component| URI.encode_www_form_component(component) }.join("/")
        URI::S3.new("s3", nil, bucket_name, nil, nil, "/#{path}", nil, nil, nil)
      end

      alias build build_s3
    end

    private

    def s3_key
      URI.decode_www_form_component(path[1..-1])
    end

    def s3_resource(**options)
      @s3_resource ||= Aws::S3::Resource.new(options)
    end
  end

  if respond_to?(:register_scheme)
    register_scheme "S3", S3
  else
    @@schemes["S3"] = S3
  end
end
