class CpfValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    cpf = value.to_s.gsub(/\D/, "")

    return if cpf.blank? && options[:allow_blank]

    if cpf.blank?
      record.errors.add(
        attribute,
        options[:message] || "não pode ficar em branco"
      )

      return
    end

    unless CPF.valid?(cpf)
      record.errors.add(
        attribute,
        options[:message] || "não é um CPF válido"
      )
    end
  end
end