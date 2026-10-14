NEXVION FINAL WEBSITE

Pages:
- index.html       Home page
- products.html    Product listing/filter page
- payment.html     Separate checkout/payment page

CSS:
- style.css
- products.css
- payment.css

JavaScript:
- script.js
- payment.js

Assets:
- logo.png

Features:
- Product catalogue with 12 products
- Product images with fallback placeholders
- Category filters
- Price filter
- Stock filter
- Sorting
- Search
- Cart with quantity controls
- Login
- Registration
- Logout
- LocalStorage account/cart persistence
- Separate payment page
- Phone: exactly 10 digits
- PIN: exactly 6 digits
- Card number: 16 digits
- CVV: 3 digits
- Card expiry: MM/YY
- UPI validation
- COD option
- Order confirmation

Note:
Authentication and payment are frontend demo functionality using localStorage.
A real production store should use a backend/authentication service and a real payment gateway.

## Docker Deployment

### Prerequisites
- Linux
- Docker Engine
- Docker Compose plugin
- Git

### Run the application

Clone the repository and enter the project directory:

    git clone <YOUR_GITHUB_REPOSITORY_URL>
    cd Nexvion

Build and start the application:

    docker compose up -d --build

Open the application locally:

    http://localhost:8080

### Verify deployment

    docker compose ps
    docker compose logs --tail 50 nexvion-web
    curl -I http://localhost:8080

### Stop the application

    docker compose down

## Architecture

- Frontend: HTML, CSS, JavaScript
- Web server: Nginx
- Containerization: Docker
- Deployment orchestration: Docker Compose
- Health monitoring: Docker HEALTHCHECK

## Demo Limitations

Authentication and payment are frontend demo functionality using localStorage.
A production deployment requires a backend, server-side authentication,
secure data storage, and a real payment gateway.
