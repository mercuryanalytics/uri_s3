# frozen_string_literal: true

require 'uri'

module URI
  class S3 < Generic
    def s3_bucket(options = {})
      @s3_bucket ||= s3_resource(options).bucket(host)
    end

    def s3_object(options = {})
      @s3_object ||= s3_bucket(options).object(s3_key)
    end

    def download_file(filename, options = {})
      client_options = options.fetch(:client, {})
      get_params = options.fetch(:params, {})
      file_options = options.fetch(:file, {})
      Aws::S3::Client.new(client_options).get_object(get_params).download_file(filename, file_options)
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
