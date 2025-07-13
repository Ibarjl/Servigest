module NotificationService

export send_email, send_sms

function send_email(to::String, subject::String, body::String)
    # Aquí se implementaría la lógica para enviar un correo electrónico
    println("Enviando correo a: $to")
    println("Asunto: $subject")
    println("Cuerpo: $body")
end

function send_sms(to::String, message::String)
    # Aquí se implementaría la lógica para enviar un SMS
    println("Enviando SMS a: $to")
    println("Mensaje: $message")
end

end # module NotificationService