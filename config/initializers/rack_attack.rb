# config/initializers/rack_attack.rb
class Rack::Attack
  # 1. Limitar tentativas de login (Segurança)
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == '/session' && req.post?
  end

  # 2. Proteção para o momento de abertura de inscrições (Escala)
  # Permite 100 requisições por minuto por IP na rota de inscrição
  throttle('registrations/ip', limit: 100, period: 1.minute) do |req|
    req.ip if req.path.include?('/inscrever') && req.post?
  end

  # Resposta customizada quando o limite é atingido
  self.throttled_responder = lambda do |request|
    [ 429,  { 'Content-Type' => 'text/html' }, [ "Muitos acessos. Aguarde um momento e tente novamente." ] ]
  end
end