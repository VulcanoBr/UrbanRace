
# frozen_string_literal: true

class Organizer::ResultHomologatorService
  def self.call(result)
    new(result).call
  end

  def initialize(result)
    @result = result
  end

  def call
    return @result if @result.homologado?

    ActiveRecord::Base.transaction do
      @result.update!(
        homologado: true,
        homologado_em: Time.current
      )
    end

    Certificates::GenerateSingleJob.perform_later(@result.id)

    @result
  end
end
