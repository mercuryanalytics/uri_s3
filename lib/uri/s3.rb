# frozen_string_literal: true

require 'uri'

module URI
  class S3 < Generic
    def s3_bucket(options = {})
      @s3_bucket ||= s3_resource(options).bucket(host)
    end

    def s3_object(options = {})
      @s3_object ||= s3_bucket(options).object(URI.decode_www_form_component(path[1..-1]))
    end

    private

    def s3_resource(options = {})
      @s3_resource ||= Aws::S3::Resource.new(options)
    end
  end

  @@schemes['S3'] = S3
end
