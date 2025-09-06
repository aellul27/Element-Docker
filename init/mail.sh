#!/bin/bash

# Generate email config if SMTP_HOST is set
generate_email_config() {
	if [[ -n "${SMTP_HOST:-}" ]]; then
		# Check if SMTP password secret exists
		local smtp_auth=""
		if [[ -s /secrets/smtp_password ]]; then
			smtp_auth="  smtp_user: ${SMTP_USER}
  smtp_pass: $(</secrets/smtp_password)"
		fi
		
		export EMAIL_CONFIG="email:
  smtp_host: ${SMTP_HOST}
  smtp_port: ${SMTP_PORT}
${smtp_auth}
  enable_tls: true
  force_tls: false
  require_transport_security: true
  notif_from: \"Your %(app)s homeserver <${MAIL_NOTIF_FROM_ADDRESS}>\"
  app_name: Matrix
  enable_notifs: true
  notif_for_new_users: false
  client_base_url: https://${ELEMENT_WEB_FQDN}
  validation_token_lifetime: 15m
  invite_client_location: https://${ELEMENT_WEB_FQDN}
  subjects:
    message_from_person_in_room: \"[%(app)s] You have a message on %(app)s from %(person)s in the %(room)s room...\"
    message_from_person: \"[%(app)s] You have a message on %(app)s from %(person)s...\"
    messages_from_person: \"[%(app)s] You have messages on %(app)s from %(person)s...\"
    messages_in_room: \"[%(app)s] You have messages on %(app)s in the %(room)s room...\"
    messages_in_room_and_others: \"[%(app)s] You have messages on %(app)s in the %(room)s room and others...\"
    messages_from_person_and_others: \"[%(app)s] You have messages on %(app)s from %(person)s and others...\"
    invite_from_person_to_room: \"[%(app)s] %(person)s has invited you to join the %(room)s room on %(app)s...\"
    invite_from_person: \"[%(app)s] %(person)s has invited you to chat on %(app)s...\"
    password_reset: \"[%(server_name)s] Password reset\"
    email_validation: \"[%(server_name)s] Validate your email\"

registrations_require_3pid:
  - email"
	else
		export EMAIL_CONFIG=""
	fi
}
