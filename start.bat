@echo off
echo 🚀 Starting Civic Issue Management System...
echo.
echo 📋 Make sure you have:
echo    1. Created a .env file with your Supabase credentials
echo    2. Installed requirements: pip install -r requirements.txt
echo    3. Run migrations: python manage.py migrate
echo.
echo 🌐 Your website will be available at:
echo    Main Dashboard: http://localhost:8000
echo    Test Page: http://localhost:8000/test/
echo.
echo Press any key to start the server...
pause
python manage.py runserver
