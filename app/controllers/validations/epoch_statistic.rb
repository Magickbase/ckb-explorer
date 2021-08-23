module Validations
  class EpochStatistic
    include ActiveModel::Validations

    validate :query_key_format_must_be_correct

    def initialize(params = {})
      @query_key = params[:id]
    end

    def error_object
      api_errors = []

      if invalid?
        api_errors << Api::V1::Exceptions::IndicatorNameInvalidError.new if :query_key.in?(errors.attribute_names)
        {
          status: api_errors.first.status,
          errors: RequestErrorSerializer.new(api_errors, message: api_errors.first.title)
        }
      end
    end

    private

    attr_accessor :query_key

    def query_key_format_must_be_correct
      if query_key.blank? || !query_key.split("-").map { |item| item.in?(::EpochStatistic::VALID_INDICATORS) }.all?(true)
        errors.add(:query_key, "indicator name is invalid")
      end
    end
  end
end
