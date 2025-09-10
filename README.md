# Element Docker

A comprehensive Docker Compose setup for running a complete Matrix ecosystem with Element clients, including video calling capabilities.

## Overview

This project provides a production-ready Docker Compose setup for:

- **Synapse** - Matrix homeserver
- **Element Web** - Web-based Matrix client
- **Element Call** - Video calling application
- **Synapse Admin** - Administration interface for Synapse
- **LiveKit** - Video/audio infrastructure for Element Call
- **PostgreSQL** - Database backend
- **Redis** - Caching and session storage

## Features

- ✅ Complete Matrix server setup with federation support
- ✅ Video calling with LiveKit integration
- ✅ Email notifications and registration
- ✅ reCAPTCHA support for registration
- ✅ Admin interface for user management
- ✅ Secure secret management
- ✅ Health checks and proper service dependencies
- ✅ Template-based configuration system

## Quick Start

### Prerequisites

- Docker and Docker Compose
- A domain name with DNS properly configured
- Ports 8008-8012, 7880-7885 available

### Initial Setup

1. **Clone and prepare the environment:**
   ```bash
   git clone <repository-url>
   cd "Element Docker"
   chmod +x setup.sh
   ./setup.sh
   ```

2. **Configure your domain:**
   - The setup script will prompt for your base domain (e.g., `example.com`)
   - Update DNS records to point subdomains to your server:
     - `matrix.example.com` → Synapse homeserver
     - `element.example.com` → Element Web client
     - `call.example.com` → Element Call
     - `livekit.example.com` → LiveKit server

3. **Start the services:**
   ```bash
   docker compose up -d
   ```

### First Run

The first startup will:
1. Generate Synapse configuration and secrets
2. Initialize the PostgreSQL database
3. Template all configuration files
4. Start all services in the correct order

## Configuration

### Environment Variables

All configuration is managed through the `.env` file (created from `.env-sample`):

| Variable | Description | Example |
|----------|-------------|---------|
| `DOMAIN` | Your base domain | `example.com` |
| `HOMESERVER_FQDN` | Matrix server URL | `matrix.example.com` |
| `ELEMENT_WEB_FQDN` | Element Web URL | `element.example.com` |
| `ELEMENT_CALL_FQDN` | Element Call URL | `call.example.com` |
| `LIVEKIT_FQDN` | LiveKit server URL | `livekit.example.com` |
| `LIVEKIT_NODE_IP` | LiveKit public IP | Your server's public IP |
| `REPORT_STATS` | Send usage stats to Matrix.org | `yes` or `no` |

### Email Configuration (Optional)

To enable email notifications and registration:

```bash
# Uncomment and configure in .env
SMTP_HOST=your.smtp.server
SMTP_PORT=587
MAIL_NOTIF_FROM_ADDRESS=noreply@example.com
SMTP_USER=your_email_user
```

Then create the SMTP password secret:
```bash
echo "your_smtp_password" > secrets/smtp_password
```

### reCAPTCHA (Optional)

To enable reCAPTCHA for registration:

1. Get keys from [Google reCAPTCHA](https://www.google.com/recaptcha/)
2. Save them:
   ```bash
   echo "your_site_key" > secrets/recaptcha/public
   echo "your_secret_key" > secrets/recaptcha/private
   ```

## Service URLs

After setup, access your services at:

- **Element Web**: http://localhost:8010 (or https://element.example.com)
- **Synapse Admin**: http://localhost:8009
- **Element Call**: http://localhost:8012
- **LiveKit JWT Service**: http://localhost:8011
- **Synapse**: http://localhost:8008

## Directory Structure

```
├── compose.yml              # Main Docker Compose file
├── .env                     # Environment configuration
├── setup.sh                 # Initial setup script
├── data/                    # Runtime data (auto-generated)
├── data-template/           # Configuration templates
│   ├── synapse/
│   ├── element-web/
│   ├── element-call/
│   └── livekit/
├── secrets/                 # Generated secrets
│   ├── synapse/
│   ├── postgres/
│   └── livekit/
├── init/                    # Initialization scripts
└── scripts/                 # Helper scripts
```

## Administration

### Creating Users

Use Synapse Admin (http://localhost:8009) or the command line:

```bash
docker compose exec synapse register_new_matrix_user -c /data/homeserver.yaml http://localhost:8008
```

### Viewing Logs

```bash
# All services
docker compose logs

# Specific service
docker compose logs synapse
docker compose logs element-web
```

### Updating

```bash
docker compose pull
docker compose up -d
```

## Troubleshooting

### Video Calls Not Working

1. Check that `LIVEKIT_NODE_IP` in `.env` matches your server's public IP
2. Ensure UDP ports 7882-7885 are open in your firewall
3. Verify LiveKit is accessible at your configured FQDN

### Federation Issues

1. Verify DNS records for `matrix.example.com`
2. Check that port 8008 is accessible externally
3. Test federation with the [Matrix Federation Tester](https://federationtester.matrix.org/)

### Email Not Working

1. Verify SMTP configuration in `.env`
2. Check that `secrets/smtp_password` exists and contains the correct password
3. Review Synapse logs for email-related errors

## Security Considerations

- All secrets are automatically generated and stored in the `secrets/` directory
- Database passwords are randomly generated
- Synapse signing keys are properly managed
- Services run with non-root users where possible

## Advanced Configuration

### Custom Templates

Modify files in `data-template/` to customize configurations. The init container will template these with environment variables.

### Additional Databases

The PostgreSQL setup creates separate databases for `synapse` and `mas` (Matrix Authentication Service).

### Reverse Proxy

For production, use a reverse proxy like Nginx or Traefik to handle TLS termination and routing to the various services.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with a clean environment
5. Submit a pull request

## License

See [LICENSE.md](LICENSE.md) for details.

## Support

- Issues: GitHub Issues
- Documentation: [Matrix.org docs](https://matrix.org/docs/)
- Documentation: [Synapse docs](https://element-hq.github.io/synapse/latest/welcome_and_overview.html)
