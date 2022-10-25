#frozen_string_literal: true

require "uri/s3"

RSpec.describe URI::S3, type: :lib do
  before do
    Aws.config[:region] = "us-east-1"
    Aws.config[:credentials] = Aws::SharedCredentials.new rescue nil
  end

  context "#index" do
    it "registers the s3 scheme to uri class" do
      expect(URI("s3://bucket/path/file.ext")).to be_a URI::S3
    end
  end
end
