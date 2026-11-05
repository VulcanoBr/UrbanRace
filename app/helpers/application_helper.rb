module ApplicationHelper

  def format_phone(phone, fallback: "Não informado")
    return fallback if phone.blank?

    # Remove tudo que não for número
    digits = phone.to_s.gsub(/\D/, "")

    case digits.length
    when 11 # Celular: (99) 99999-9999
      "(#{digits[0..1]}) #{digits[2..6]}-#{digits[7..10]}"
    when 10 # Fixo: (99) 9999-9999
      "(#{digits[0..1]}) #{digits[2..5]}-#{digits[6..9]}"
    else
      # Se o formato for desconhecido (ex: internacional), retorna o original ou limpo
      phone
    end
  end

  def format_cpf(cpf)
    return "-" if cpf.blank?

    digits = cpf.to_s.gsub(/\D/, "")

    return cpf if digits.length != 11

    "#{digits[0..2]}.#{digits[3..5]}.#{digits[6..8]}-#{digits[9..10]}"
  end

  def formatar_cnpj(cnpj)
    return "-" if cnpj.blank?

    # Remove qualquer caractere que não seja número
    texto = cnpj.to_s.gsub(/\D/, "")

    # Aplica a máscara: 00.000.000/0000-00
    texto.gsub(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '\1.\2.\3/\4-\5')
  end

  def format_pace(pace_decimal)
    minutos = pace_decimal.to_i
    segundos = ((pace_decimal - minutos) * 60).round
    format("%02d:%02d", minutos, segundos)
  end
  
end
