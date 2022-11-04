# frozen_string_literal: true

require "uri"
require "aws-sdk-s3"

module URI
  class S3 < Generic
    def s3_bucket(options = {})
      @s3_bucket ||= begin
                       options[:region] = s3_region unless options.key?(:region)
                       s3_resource(options).bucket(host)
                     end
    end

    def s3_region
      @s3_region ||= begin
                       region = Aws::S3::Client.new.get_bucket_location(bucket: host).location_constraint
                       if region.empty?
                         "us-east-1"
                       else
                         region
                       end
                     end
    end

    def s3_object(options = {})
      @s3_object ||= s3_bucket(options).object(s3_key)
    end

    def index(options = {})
      params = { bucket: host, prefix: path[1..-1], max_keys: 1000 }
      Enumerator.new do |yielder|
        client = Aws::S3::Client.new(options)
        loop do
          resp = client.list_objects_v2(params)
          resp.contents.each {|entry| yielder << entry }
          break unless resp.is_truncated

          params[:continuation_token] = resp.next_continuation_token
        end
      end
    end

    def fetch(options = {})
      s3_object(options).get.body
    end

    def get(options = {})
      s3_object.get.body.read
    end

    def put(body:, **options)
      s3_object.put(body:, **options)
    end

    def download_file(filename, options = {})
      client_options = options.fetch(:client, {})
      get_params = options.fetch(:params, {})
      file_options = options.fetch(:file, {})
      Aws::S3::Client.new(client_options).get_object(get_params).download_file(filename, file_options)
    end

    def upload_file(file, options = {})
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

    def destroy
      s3_object.delete
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

    def s3_resource(options = {})
      @s3_resource ||= Aws::S3::Resource.new(options)
    end
  end

  if respond_to?(:register_scheme)
    register_scheme "S3", S3
  else
    @@schemes["S3"] = S3
  end
end
