module Certificates
  class GenerateSingleJob < ApplicationJob
    queue_as :background

    retry_on ActiveRecord::Deadlocked,
             wait: :polynomially_longer,
             attempts: 3

    def perform(result_id)
      result = Result.find(result_id)

      return unless result.certificado_geravel?

      Certificates::GeneratorService.generate(result)
    end
  end
end