# WIPS Centralized Event Calendar

## Overview
A Ruby on Rails web application built for the **Women in Public Service (WIPS)** organization to centralize event scheduling, member sign-ups, and attendance tracking.  
The system allows users to view upcoming events, register, check in, and view dashboards of past activities.  
Admins can create events, export attendance, view analytics, and manage member engagement, improving transparency and reducing manual coordination.

---

## Tech Stack
- **Ruby** 3.3.9  
- **Rails** 8.0.2.1  
- **PostgreSQL** (Heroku Postgres)
- **Bootstrap 5**, **Turbo**, and **Stimulus** (via js/css-bundling)
- **Devise** + **OmniAuth-Google-OAuth2** (secure Google login)
- **RQRCode** (QR code generation)
- **RSpec**, **Capybara**, **SimpleCov** (testing & coverage)
- **Brakeman**, **RuboCop** (security & linting)
- **Solid Queue / Solid Cable** (background jobs & real-time updates)
- **Heroku** (hosting & deployment)
- **GitHub Actions** (continuous integration / delivery)

---

## Local Setup

```bash
git clone https://github.com/500-Service-CSCE-431/Customer-Web-App.git
cd Customer-Web-App
docker compose up --build
````

Then visit **[http://localhost:3000](http://localhost:3000)** in your browser.

---

## Deployment to Heroku

```bash
heroku create customer-web-app-fa71930f523c
git push heroku main
heroku run rails db:migrate
```

### Environment Variables

| Variable               | Purpose                           |
| ---------------------- | --------------------------------- |
| `GOOGLE_CLIENT_ID`     | Enables Google OAuth login        |
| `GOOGLE_CLIENT_SECRET` | OAuth credential                  |
| `ANNOUNCEMENT_TEXT`    | Displays the bulletin banner text |
| `DATABASE_URL`         | PostgreSQL connection string      |
| `RAILS_MASTER_KEY`     | Used for encrypted credentials    |
| `SECRET_KEY_BASE`      | Rails secret for production       |

These can be configured in **Heroku → Settings → Config Vars.**

---

## Backup / Restore

Use Heroku’s built-in PostgreSQL backups to protect data.

```bash
# Capture a backup
heroku pg:backups:capture -a customer-web-app-fa71930f523c

# Download a backup
heroku pg:backups:download -a customer-web-app-fa71930f523c
```

To restore from a backup:

```bash
heroku pg:backups:restore 'https://path/to/backup.dump' DATABASE_URL -a customer-web-app-fa71930f523c
```

---

## Admin Access

Admins are identified by the `role` field in the `admin` table.
Only Admins can add, edit, or delete events and view attendance reports.
Regular members can sign up for events, check in via QR code, and view their dashboard.

---

## Quality & Security Tools

* **RuboCop** — ensures code consistency and readability.
* **Brakeman** — scans for Rails security vulnerabilities.
* **SimpleCov** — tracks automated test coverage.
* **RSpec/Capybara** — functional, integration, and regression tests.

To run all checks locally:

```bash
bundle exec rubocop
bundle exec brakeman
bundle exec rspec
```

---

## Troubleshooting

| Issue                   | Resolution                                                 |
| ----------------------- | ---------------------------------------------------------- |
| App won’t start locally | Run `rails db:migrate` and ensure PostgreSQL is running    |
| OAuth login error       | Confirm Google credentials in `.env` or Heroku Config Vars |
| Deployment failed       | Run `heroku logs --tail` to view build errors              |
| Database missing data   | Run `rails db:seed`                                        |
| Roll back bad deploy    | `heroku rollback -a customer-web-app-fa71930f523c`         |

---

## Contact & Support

For questions, training, or support:

**WIPS Leadership:** `wipstamu@gmail.com`
**Development Team – Service-500 (CSCE 431):**

* Yuexin Zhang – `zyx-0726@tamu.edu`
* Michael Rupprecht – `michael.rupprecht@tamu.edu`
* Isaac Geng – `isaacgeng@tamu.edu`

Production App → [https://customer-web-app-fa71930f523c.herokuapp.com/](https://customer-web-app-fa71930f523c.herokuapp.com/)
