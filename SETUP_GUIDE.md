# 🚀 Supabase + Django Setup Guide

## Step 1: Create your .env file
Create a file named `.env` in your project root with these contents:

```
# Django Settings
SECRET_KEY=your-secret-key-here-change-this-in-production
DEBUG=True

# Supabase Database Settings
# Get these from your Supabase project settings -> Database
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=your-supabase-password
DB_HOST=your-project-ref.supabase.co
DB_PORT=5432
```

## Step 2: Get your Supabase credentials
1. Go to [supabase.com](https://supabase.com)
2. Sign in to your account
3. Go to your project
4. Click on "Settings" → "Database"
5. Copy the connection details and paste them in your .env file

## Step 3: Run the setup commands
```bash
# Install packages (already done)
pip install -r requirements.txt

# Run migrations to create database tables
python manage.py makemigrations
python manage.py migrate

# Create a superuser (optional)
python manage.py createsuperuser

# Run the development server
python manage.py runserver
```

## Step 4: Access your website
Open your browser and go to: http://localhost:8000

## 🎯 What your website does:
- **Admin Dashboard**: View all civic issues reported by citizens
- **Real-time Data**: Fetches data directly from your Supabase database
- **Issue Management**: Mark issues as resolved, view statistics
- **Beautiful UI**: Modern, responsive design with charts and tables

## 🔧 Troubleshooting:
- If you get database connection errors, check your .env file
- Make sure your Supabase project is active
- Check that your database password is correct
