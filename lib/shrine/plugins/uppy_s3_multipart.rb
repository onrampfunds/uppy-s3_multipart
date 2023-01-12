require "uppy/s3_multipart"

class Shrine
  module Plugins
    module UppyS3Multipart
      def self.configure(uploader, options = {})
        uploader.opts[:uppy_s3_multipart_options] = (uploader.opts[:uppy_s3_multipart_options] || {}).merge(options[:options] || {})
      end

      module ClassMethods
        def uppy_s3_multipart(storage_key, **options)
          s3 = find_storage(storage_key)

          unless defined?(Shrine::Storage::S3) && s3.is_a?(Shrine::Storage::S3)
            if Rails.env.test?
              puts "Warning: expected storage on Shrine.uppy_s3_multipart to be a Shrine::Storage::S3, but was #{s3.inspect}"
            else
              fail Error, "expected storage on Shrine.uppy_s3_multipart to be a Shrine::Storage::S3, but was #{s3.inspect}"
            end
          end

          options[:bucket]  ||= s3.try(:bucket)
          options[:prefix]  ||= s3.try(:prefix)
          options[:public]  ||= s3.public if s3.respond_to?(:public)
          options[:options] ||= opts[:uppy_s3_multipart_options]

          ::Uppy::S3Multipart::App.new(**options)
        end
      end
    end

    register_plugin(:uppy_s3_multipart, UppyS3Multipart)
  end
end
