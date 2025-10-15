# Event Management System

A comprehensive event management system built with Ruby on Rails, integrated with Tito API for ticket management and featuring Docker containerization for seamless development.

## 🚀 Project Setup

Follow these steps to set up the project locally using Docker:

### Step 1: Clone the Repository
```bash
git clone https://github.com/sarahramadan/event_management_system.git
```

### Step 2: Navigate to Project Directory
```bash
cd event_management_system
```

### Step 3: Set Up Public Tunnel (Required for Tito Webhooks)
Open PowerShell (Windows) or Terminal (Linux/Mac) and run:
```bash
ssh -R 80:localhost:4000 serveo.net
```
**Note:** This creates a public tunnel for your local development server, allowing Tito webhooks to reach your application. Copy the generated URL (e.g., `https://xyz123.serveo.net`) for the next step.

### Step 4: Configure Tito API Integration
1. Login to your [Tito Dashboard](https://ti.to/)
2. Navigate to your event settings
3. Update the following credentials:
   - **BASE_URL**: `https://api.tito.io/v3`
   - **ACCOUNT_SLUG**: Your Tito account slug
   - **EVENT_SLUG**: Your event slug
   - **API_TOKEN**: Generate from Tito API settings
   - **WEBHOOK_SECRET**: Generate webhook secret

### Step 5: Create Environment Configuration
Create a new `.env.local` file in the project root with the following variables:

```bash
# Local development environment variables
DB_HOST=localhost
DB_USERNAME=postgres
DB_PASSWORD=postgres
RAILS_ENV=development

# Local development Tito API credentials
TITO_BASE_URL=https://api.tito.io/v3
TITO_ACCOUNT_SLUG=your-account-slug
TITO_EVENT_SLUG=your-event-slug
TITO_API_TOKEN=your-api-token
TITO_WEBHOOK_SECRET=your-webhook-secret
DEVELOPMENT_HOSTS=your-serveo-url.serveo.net
```

### Step 6: Build and Start Docker Containers
**For Windows (PowerShell):**
```powershell
$env:DEVELOPMENT_HOSTS="your-serveo-url.serveo.net"; docker-compose up --build
```

**For Linux/Mac:**
```bash
DEVELOPMENT_HOSTS="your-serveo-url.serveo.net" docker-compose up --build
```

Replace `your-serveo-url.serveo.net` with the URL generated in Step 3.

### Step 7: Start the Application (Subsequent Runs)
For subsequent runs after the initial build:
```bash
docker-compose up
```

### Step 8: Access the Application
Open your browser and navigate to:
```
http://localhost:4000
```

### Step 9: Admin Access
The application comes with a pre-seeded admin user. You can also register a new admin account:

**Default Admin Credentials:**
- **Email:** `admin@eventmanagement.com`
- **Password:** `AdminPassword123!`

### Step 10: Email Confirmation (Development)
If you encounter issues with email confirmation during development, access the email viewer at:
```
http://localhost:4000/letter_opener
```

### Step 11: Login to Admin Panel
Use the credentials from Step 9 to access the admin panel and manage events, tickets, and users.

## 🛠 Technology Stack

- **Backend:** Ruby on Rails
- **Database:** PostgreSQL
- **Containerization:** Docker & Docker Compose
- **Email Development:** Letter Opener Web
- **API Integration:** Tito Events API
- **Authentication:** Devise & JWT
- **API Documentation:** Swagger/OpenAPI (RSwag)

## 🗄️ Database Structure

The application uses PostgreSQL as the primary database with the following schema:

### 👤 Users Table
| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `email` | string | User email (unique, required) |
| `encrypted_password` | string | Encrypted password via Devise |
| `name` | string | User full name (required, 2-50 chars) |
| `phone_number` | string | User contact number (optional) |
| `role` | integer | User role enum (1: attendee, 2: admin) |
| `confirmation_token` | string | Email confirmation token |
| `confirmed_at` | datetime | Email confirmation timestamp |
| `reset_password_token` | string | Password reset token |
| `created_at` | datetime | Record creation timestamp |
| `updated_at` | datetime | Record update timestamp |

**Indexes:**
- Unique index on `email`
- Unique index on `confirmation_token`
- Unique index on `reset_password_token`
- Index on `role`

### 🎫 Tickets Table
| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `reference_id` | string | Unique ticket reference from Tito |
| `reference_code` | string | Ticket reference code |
| `user_id` | bigint | Foreign key to users table |
| `ticket_status_id` | bigint | Foreign key to ticket_statuses table |
| `purchase_date` | datetime | Ticket purchase timestamp |
| `release_name` | string | Ticket release/type name |
| `quantity` | integer | Number of tickets purchased |
| `price` | decimal | Ticket price |
| `deleted_at` | datetime | Soft delete timestamp |
| `created_at` | datetime | Record creation timestamp |
| `updated_at` | datetime | Record update timestamp |

**Indexes:**
- Unique index on `reference_id`
- Index on `reference_code`
- Index on `user_id`
- Index on `ticket_status_id`
- Composite index on `user_id` and `ticket_status_id`
- Index on `purchase_date`
- Index on `deleted_at` (for soft deletes)

### 📊 Ticket Statuses Table
| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `name` | string | Status name (unique, required) |
| `description` | text | Status description |
| `created_at` | datetime | Record creation timestamp |
| `updated_at` | datetime | Record update timestamp |

**Indexes:**
- Unique index on `name`

**Default Statuses:**
- `complete` - Ticket fully processed and assigned
- `incomplete` - Ticket created but missing data
- `unassigned` - Ticket not linked to any user
- `void` - Ticket canceled or invalid

### 🔗 Foreign Key Relationships
```
users (1) ←→ (many) tickets
ticket_statuses (1) ←→ (many) tickets
```

**Cascade Rules:**
- `tickets.user_id` → `users.id` (ON DELETE RESTRICT)
- `tickets.ticket_status_id` → `ticket_statuses.id` (ON DELETE SET NULL)

### 🏗️ Database Migrations
The database schema is managed through Rails migrations located in `db/migrate/`:

- `20251009141944_devise_create_users.rb` - Initial Devise user setup
- `20251009143421_add_role_to_users.rb` - Add role enum to users
- `20251009162258_add_confirmable_to_users.rb` - Email confirmation
- `20251010110152_add_name_to_users.rb` - Add name field
- `20251012010858_create_ticket_statuses.rb` - Ticket status table
- `20251012010921_create_tickets.rb` - Main tickets table

### 🌱 Database Seeding
The `db/seeds.rb` file contains:
- **Ticket Statuses**: All default status types
- **Admin User**: Default admin account (admin@eventmanagement.com)

Run seeds with: `docker-compose exec web rails db:seed`

## 📋 Prerequisites

- Docker and Docker Compose installed
- Git installed
- Access to Tito account (for API integration)
- PowerShell (Windows) or Terminal (Linux/Mac)

## 🔧 Development Notes

- The application runs on port 4000 in development
- PostgreSQL database runs on port 5434
- Email previews are available via Letter Opener Web
- Tito webhook integration requires public URL (serveo.net tunnel)

## 📖 API Documentation with Swagger

The Event Management System provides a comprehensive RESTful API documented with Swagger/OpenAPI specifications.

### Accessing Swagger Documentation
Once the application is running, access the interactive API documentation at:
```
http://localhost:4000/api-docs
```

### Available API Endpoints

#### 🔐 Authentication Endpoints
- **POST** `/api/v1/auth/login` - User login
- **DELETE** `/api/v1/auth/logout` - User logout
- **POST** `/api/v1/register` - User registration

#### 👤 User Profile Endpoints
- **GET** `/api/v1/profile` - Get current user profile

#### 🎫 Ticket Management Endpoints
- **GET** `/api/v1/tickets/:id` - Get specific ticket details

#### 🔗 Tito Integration Endpoints
- **POST** `/api/v1/webhook` - Tito webhook receiver
- **GET** `/api/v1/tito/test_connection` - Test Tito API connection
- **GET** `/api/v1/tito/attendee_tickets` - Get attendee tickets from Tito

### API Authentication
The API uses JWT (JSON Web Tokens) for authentication:

1. **Login** via `POST /api/v1/auth/login` with email and password
2. **Receive JWT token** in response
3. **Include token** in subsequent requests:
   ```
   Authorization: Bearer <your-jwt-token>
   ```

### Example API Usage

#### User Registration
```bash
curl -X POST http://localhost:4000/api/v1/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "John Doe",
      "email": "john@example.com",
      "password": "secure_password"
    }
  }'
```

#### User Login
```bash
curl -X POST http://localhost:4000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "secure_password"
  }'
```

#### Get User Profile (Authenticated)
```bash
curl -X GET http://localhost:4000/api/v1/profile \
  -H "Authorization: Bearer <your-jwt-token>"
```

### API Response Format
All API responses follow a consistent JSON format:

**Success Response:**
```json
{
  "status": "success",
  "data": { ... },
  "message": "Operation successful"
}
```

**Error Response:**
```json
{
  "status": "error",
  "message": "Error description",
  "errors": [ ... ]
}
```

### Testing the API
- **Swagger UI**: Interactive testing at `http://localhost:4000/api-docs`
- **Postman**: Import the OpenAPI spec from `/api-docs/v1/swagger.json`

## 📚 Additional Information

* **Ruby version:** 3.4.6
* **System dependencies:** Docker, Docker Compose
* **Database:** PostgreSQL 15
* **Test suite:** RSpec (run with `docker-compose exec web bundle exec rspec`)
* **API Documentation:** Available at `/api-docs` when running using swagger
* **Services:** Background job processing, email delivery
* **Deployment:** Docker-based deployment ready


## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
