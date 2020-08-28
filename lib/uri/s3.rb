# frozen_string_literal: true

require 'uri'

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
        loop do
          resp = s3_client(options).list_objects_v2(params)
          resp.contents.each { |entry| yielder << entry }
          break unless resp.is_truncated

          params[:continuation_token] = resp.next_continuation_token
        end
      end
    end

    def fetch(options = {})
      s3_object(options).body
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

    class << self
      def build_s3(bucket_name, key = "/")
        path = key.split("/").map { |component|  URI.encode_www_form_component(component) }.join("/")
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

  @@schemes['S3'] = S3
end
