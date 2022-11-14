# frozen_string_literal: true

require "spec_helper"
require "uri/s3"

RSpec.describe URI::S3, type: :lib do
  subject { URI("s3://bucket/path/file.ext") }

  let(:client) { instance_double(Aws::S3::Client) }
  let(:resource) { instance_double(Aws::S3::Resource) }

  before do
    Aws.config[:region] = "us-east-1"
    Aws.config[:credentials] = Aws::SharedCredentials.new rescue nil # rubocop:disable Style/RescueModifier
    allow(Aws::S3::Client).to receive(:new).and_return client
    allow(Aws::S3::Resource).to receive(:new).and_return resource
  end

  it "registers the s3 scheme to uri class" do
    expect(subject).to be_a described_class
  end

  describe "#index" do
    let(:r1) do
      Aws::S3::Types::ListObjectsV2Output.new(
        { "is_truncated" => true,
          "contents" => [
            { "key" => "demos/fanfold/", "last_modified" => DateTime.parse("2021-05-04 18:42:50 UTC"), "etag" => "\"d41d8cd98f00b204e9800998ecf8427e\"", "size" => 0, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/0001.jpg", "last_modified" => DateTime.parse("2021-05-14 16:09:34 UTC"), "etag" => "\"46fb17ffa489d6ff304f39e044777628\"", "size" => 765482, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/0002.jpg", "last_modified" => DateTime.parse("2021-05-14 16:09:37 UTC"), "etag" => "\"4375caaaf9c60d30a1a5781ec26894a9\"", "size" => 1114195, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_TOUCH_1_50-1.jpg", "last_modified" => DateTime.parse("2021-05-14 16:09:41 UTC"), "etag" => "\"d3b9fb530f6b919f16908304dc3600b0\"", "size" => 443028, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_TOUCH_1_50-2.jpg", "last_modified" => DateTime.parse("2021-05-14 16:09:44 UTC"), "etag" => "\"1d1916b6d651b53163e7299ef50f1b21\"", "size" => 595314, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_TOUCH_1_55-1.jpg", "last_modified" => DateTime.parse("2021-05-14 16:09:47 UTC"), "etag" => "\"d1fccfd9a5073c0909fa611b5733612a\"", "size" => 436457, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_TOUCH_1_55-2.jpg", "last_modified" => DateTime.parse("2021-05-14 16:09:50 UTC"), "etag" => "\"6a1564369ba28d0a620a3c00e2f3f589\"", "size" => 610653, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_TOUCH_2_50-1.jpg", "last_modified" => DateTime.parse("2021-05-14 16:09:54 UTC"), "etag" => "\"2261e42b4b03846a1cee922e8774ea87\"", "size" => 341707, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_TOUCH_2_50-2.jpg", "last_modified" => DateTime.parse("2021-05-14 16:09:56 UTC"), "etag" => "\"df581371268cbff2fa017885bac1dc98\"", "size" => 562842, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_TOUCH_2_55-1.jpg", "last_modified" => DateTime.parse("2021-05-14 16:09:59 UTC"), "etag" => "\"4273acecece83fa2f561e91bcdc849d5\"", "size" => 354568, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_TOUCH_2_55-1_Bottom.jpg", "last_modified" => DateTime.parse("2021-05-13 19:58:45 UTC"), "etag" => "\"de9e3b3c1ba3b745f5595fffdcef2661\"", "size" => 427016, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_TOUCH_2_55-1_Top.jpg", "last_modified" => DateTime.parse("2021-05-13 19:58:45 UTC"), "etag" => "\"ea764d9966fd9128d96534eb1c7d7548\"", "size" => 106826, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_TOUCH_2_55-2.jpg", "last_modified" => DateTime.parse("2021-05-14 16:10:02 UTC"), "etag" => "\"a18a6e9eeb902d548bf1c63d28da0b23\"", "size" => 556932, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_VALPACK_50-1.jpg", "last_modified" => DateTime.parse("2021-05-14 16:10:05 UTC"), "etag" => "\"db80fce68bfb6d2d731e0fb9a759f468\"", "size" => 560527, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_VALPACK_50-2.jpg", "last_modified" => DateTime.parse("2021-05-14 16:10:08 UTC"), "etag" => "\"078812a9a3fbbaaefafcc3726aba176f\"", "size" => 604443, "storage_class" => "STANDARD" }
          ],
          "name" => "s3-assets.mercuryanalytics.com",
          "prefix" => "demos/fanfold",
          "max_keys" => 15,
          "key_count" => 15,
          "next_continuation_token" => "1x+dP66/E59stPuAADhi3L8oIjemP65OQFsZ2gkchEep7FLniGnHCSDinBPv77ikYfLV7WUwBPWUvm63sNZxQ0TAmhdJWd1F2e/PEQKHBoi4=" }
      )
    end

    let(:r2) do
      Aws::S3::Types::ListObjectsV2Output.new(
        { "is_truncated" => false,
          "contents" => [
            { "key" => "demos/fanfold/4563_VALPACK_55-1 (1).jpg", "last_modified" => DateTime.parse("2021-05-13 19:40:54 UTC"), "etag" => "\"30979f36a2b9d4e8316af0e899e7679f\"", "size" => 557944, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_VALPACK_55-1.jpg", "last_modified" => DateTime.parse("2021-05-14 16:10:12 UTC"), "etag" => "\"30979f36a2b9d4e8316af0e899e7679f\"", "size" => 557944, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/4563_VALPACK_55-2.jpg", "last_modified" => DateTime.parse("2021-05-14 16:10:15 UTC"), "etag" => "\"3ce3bf7daba52a085bde3e7befaac776\"", "size" => 597508, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/fold.png", "last_modified" => DateTime.parse("2021-05-04 21:39:25 UTC"), "etag" => "\"e9080e126a578a607ea5caa239a2008b\"", "size" => 226322, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/index.html", "last_modified" => DateTime.parse("2021-05-04 21:55:24 UTC"), "etag" => "\"eacfbcb7542658bcc3b8c4d026496965\"", "size" => 752, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/main.png", "last_modified" => DateTime.parse("2021-05-04 21:39:26 UTC"), "etag" => "\"0bb73c97e6dd457756ab5c8c47bfb11a\"", "size" => 56752, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/paperfold.js", "last_modified" => DateTime.parse("2021-05-04 21:39:26 UTC"), "etag" => "\"7c718249be570dd190855d1d24323955\"", "size" => 8264, "storage_class" => "STANDARD" },
            { "key" => "demos/fanfold/paperfold.min.js", "last_modified" => DateTime.parse("2021-05-05 23:22:09 UTC"), "etag" => "\"d68fe4bb9914c4c9fe6d47f3fd4fd8af\"", "size" => 3435, "storage_class" => "STANDARD" }
          ],
          "name" => "s3-assets.mercuryanalytics.com",
          "prefix" => "demos/fanfold",
          "max_keys" => 15,
          "key_count" => 8,
          "continuation_token" => "1x+dP66/E59stPuAADhi3L8oIjemP65OQFsZ2gkchEep7FLniGnHCSDinBPv77ikYfLV7WUwBPWUvm63sNZxQ0TAmhdJWd1F2e/PEQKHBoi4=" }
      )
    end

    it do
      allow(client).to receive(:list_objects_v2).and_return r1
      allow(client).to receive(:list_objects_v2).with(hash_including(continuation_token: "1x+dP66/E59stPuAADhi3L8oIjemP65OQFsZ2gkchEep7FLniGnHCSDinBPv77ikYfLV7WUwBPWUvm63sNZxQ0TAmhdJWd1F2e/PEQKHBoi4=")).and_return r2
      expect(subject.index.map {|e| e["key"] }.size).to eq [
        "demos/fanfold/",
        "demos/fanfold/0001.jpg",
        "demos/fanfold/0002.jpg",
        "demos/fanfold/4563_TOUCH_1_50-1.jpg",
        "demos/fanfold/4563_TOUCH_1_50-2.jpg",
        "demos/fanfold/4563_TOUCH_1_55-1.jpg",
        "demos/fanfold/4563_TOUCH_1_55-2.jpg",
        "demos/fanfold/4563_TOUCH_2_50-1.jpg",
        "demos/fanfold/4563_TOUCH_2_50-2.jpg",
        "demos/fanfold/4563_TOUCH_2_55-1.jpg",
        "demos/fanfold/4563_TOUCH_2_55-1_Bottom.jpg",
        "demos/fanfold/4563_TOUCH_2_55-1_Top.jpg",
        "demos/fanfold/4563_TOUCH_2_55-2.jpg",
        "demos/fanfold/4563_VALPACK_50-1.jpg",
        "demos/fanfold/4563_VALPACK_50-2.jpg",
        "demos/fanfold/4563_VALPACK_55-1 (1).jpg",
        "demos/fanfold/4563_VALPACK_55-1.jpg",
        "demos/fanfold/4563_VALPACK_55-2.jpg",
        "demos/fanfold/fold.png",
        "demos/fanfold/index.html",
        "demos/fanfold/main.png",
        "demos/fanfold/paperfold.js",
        "demos/fanfold/paperfold.min.js"
      ].size
    end
  end

  describe "#key" do
    it "pulls the path form subject and removes beginning /" do
      expect(subject.key).to eq "path/file.ext"
    end
  end

  describe "#build" do
    subject { described_class }

    let(:scheme) { "s3" }
    let(:bucket_name) { "test_bucket_name" }
    let(:bucket_path) { "/path/to/somewhere" }

    it "builds a URI::S3 object with correct scheme" do
      expect(subject.build_s3("test_bucket_name", "path/to/somewhere").scheme).to eq scheme
    end

    it "builds a URI::S3 object with correct bucket name as host" do
      expect(subject.build_s3("test_bucket_name", "path/to/somewhere").host).to eq bucket_name
    end

    it "builds a URI::S3 object with correct path to bucket" do
      expect(subject.build_s3("test_bucket_name", "path/to/somewhere").path).to eq bucket_path
    end

    it "creates a URI:S3 object" do
      expect(subject.build_s3("test_bucket_name", "path/to/somewhere")).to be_an_instance_of(described_class)
    end
  end

  describe "methods modifying s3_object" do
    let(:bucket_response) do
      Aws::S3::Types::GetBucketLocationOutput.new({ location_constraint: "us-east-2" })
    end

    let(:bucket) { instance_double(Aws::S3::Bucket) }
    let(:object) { instance_double(Aws::S3::Object) }

    before do
      allow(client).to receive(:get_bucket_location).and_return bucket_response
      allow(resource).to receive(:bucket).and_return bucket
      allow(bucket).to receive(:object).and_return object
    end

    describe "#fetch" do
      it "fetches the contents of a bucket on s3" do
        allow(object).to receive(:get).and_return Aws::S3::Types::GetObjectOutput.new({ body: StringIO.new("this is a test") })
        expect(subject.fetch(client:).read).to eq "this is a test"
      end
    end

    describe "#get" do
      it "gets and reads object from s3 bucket" do
        allow(object).to receive(:get).and_return Aws::S3::Types::GetObjectOutput.new({ body: StringIO.new("this is a test") })
        expect(subject.get).to eq "this is a test"
      end
    end

    describe "#put" do
      let(:body_request) { StringIO.new("this is a test") }

      it "puts the body this is a test on s3 object body" do
        allow(object).to receive(:put).with(body: body_request).and_return Aws::S3::Types::PutObjectOutput
        subject.put(body: body_request)
        expect(object).to have_received(:put).with(body: body_request)
      end
    end

    describe "#upload_file" do
      let(:mdd) { File.read(file_fixture("small.mdd")) }

      it "uploads a file to the s3 bucket" do
        allow(object).to receive(:upload_file).and_return true
        subject.upload_file(mdd)
        expect(object).to have_received(:upload_file).with(mdd, {})
      end
    end

    describe "#download_file" do
      let(:file_path) { "/path/to/cat.jpg" }

      it "downloads the file" do
        allow(object).to receive(:download_file).and_return true
        subject.download_file(file_path)
        expect(object).to have_received(:download_file).with(file_path)
      end
    end

    describe "to_http" do
      it "retrieves a public url" do
        allow(object).to receive(:public_url).and_return "https://bucket/path/file.ext"
        subject.to_http
        expect(object).to have_received(:public_url)
      end

      it "returns a http url" do
        allow(object).to receive(:public_url).and_return "https://bucket/path/file.ext"
        expect(subject.to_http).to be_an_instance_of(URI::HTTPS)
      end

      context "when passed an expiry duration" do
        it "retrieves a privte url with an expiration" do
          allow(object).to receive(:presigned_url).and_return "https://bucket/path/file.ext"
          subject.to_http(expires_in: 5)
          expect(object).to have_received(:presigned_url)
        end

        it "returns a presigned https url" do
          allow(object).to receive(:presigned_url).and_return "https://bucket/path/file.ext"
          expect(subject.to_http(expires_in: 5)).to be_an_instance_of(URI::HTTPS)
        end
      end

      context "when passing **options as params" do
        it "passes additional params to_http method" do
          allow(object).to receive(:presigned_url).and_return "https://bucket/path/file.ext"
          subject.to_http(expires_in: 5, response_content_disposition: :attachement)
          expect(object).to have_received(:presigned_url)
        end

        it "adds appropriate options in params" do
          allow(object).to receive(:presigned_url).and_return "https://bucket/path/file.ext"
          subject.to_http(expires_in: 5, response_content_disposition: :attachement)
          expect(object).to have_received(:presigned_url).with(:get, expires_in: 5, response_content_disposition: :attachement)
        end
      end
    end

    describe "upload_url" do
      it "retrieves uri::s3 to upload object to s3 bucket" do
        allow(object).to receive(:presigned_url).and_return "https://bucket/path/file.ext"
        subject.upload_url(expires_in: 5)
        expect(object).to have_received(:presigned_url)
      end

      it "passes canned acl param making url publicly accessible" do
        allow(object).to receive(:presigned_url).and_return "https://bucket/path/file.ext"
        subject.upload_url(public_read: true)
        expect(object).to have_received(:presigned_url).with(:put, acl: "public-read")
      end
    end

    describe "#exists?" do
      it "checks to make sure s3 object exists" do
        allow(object).to receive(:exists?).and_return true
        expect(subject.exists?).to be_truthy
      end
    end

    describe "public?" do
      let(:object_acl) { instance_double(Aws::S3::ObjectAcl) }
      let(:public_read_grant) { Aws::S3::Types::Grant.new(grantee: Aws::S3::Types::Grantee.new(uri: "http://acs.amazonaws.com/groups/global/AllUsers"), permission: "READ") }
      let(:admin_grant) { Aws::S3::Types::Grant.new(grantee: Aws::S3::Types::Grantee.new( display_name: "admin" ), permission: "FULL_CONTROL") }

      it "checks acl permissions on uri s3 are public" do
        allow(object).to receive(:acl).and_return object_acl
        allow(object_acl).to receive(:grants).and_return [admin_grant, public_read_grant]
        expect(subject.public?).to be_truthy
      end

      it "checks acl permissions on uri s3 are public" do
        allow(object).to receive(:acl).and_return object_acl
        allow(object_acl).to receive(:grants).and_return [admin_grant]
        expect(subject.public?).to be_falsey
      end
    end

    describe "#last_modified" do
      it "returns the last time the s3 object was modified" do
        time = Time.new(2022)
        allow(object).to receive(:last_modified).and_return time
        expect(subject.last_modified).to be time
      end
    end

    describe "permissions=" do
      let(:object_acl) { instance_double(Aws::S3::ObjectAcl) }

      it "checks acl permissions on uri s3" do
        allow(object).to receive(:acl).and_return object_acl
        allow(object_acl).to receive(:put).and_return Aws::S3::Types::PutObjectAclOutput.new
        subject.permissions = :public_read
        expect(object_acl).to have_received(:put).with(acl: "public-read")
      end
    end

    describe "content_type=" do
      it "checks acl permissions on uri s3" do
        type = "application/json"
        allow(object).to receive(:copy_from).and_return Aws::S3::Types::CopyObjectOutput.new
        subject.content_type = type
        expect(object).to have_received(:copy_from).with(object, content_type: type, metadata_directive: "REPLACE")
      end
    end

    describe "#destroy" do
      it "destroys the s3 object" do
        allow(object).to receive(:delete).and_return Aws::S3::Types::DeleteObjectOutput.new
        subject.destroy
        expect(object).to have_received(:delete)
      end
    end
  end
end
