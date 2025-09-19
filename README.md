# 🏛️ Civic Issue Management System

A beautiful, modern web application that connects to Supabase database to manage civic issues reported by citizens.

## 🌟 Features

- **📊 Admin Dashboard**: Beautiful interface to view all civic issues
- **🔗 Real-time Database**: Direct connection to Supabase PostgreSQL
- **📱 Responsive Design**: Works on desktop, tablet, and mobile
- **📈 Statistics & Charts**: Visual representation of issue data
- **✅ Issue Management**: Mark issues as resolved, track progress
- **🎨 Modern UI**: Clean, professional design with color-coded status

## 🚀 Quick Start

### Step 1: Setup Environment
1. Create a `.env` file in your project root:
```env
# Django Settings
SECRET_KEY=your-secret-key-here-change-this-in-production
DEBUG=True

# Supabase Database Settings
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=your-supabase-password
DB_HOST=your-project-ref.supabase.co
DB_PORT=5432
```

### Step 2: Get Supabase Credentials
1. Go to [supabase.com](https://supabase.com) and sign in
2. Create a new project or use existing one
3. Go to Settings → Database
4. Copy the connection details to your `.env` file

### Step 3: Install & Run
```bash
# Install dependencies
pip install -r requirements.txt

# Create database tables
python manage.py makemigrations
python manage.py migrate

# Create sample data (optional)
python manage.py create_sample_data

# Start the server
python manage.py runserver
```

### Step 4: Access Your Website
- **Main Dashboard**: http://localhost:8000
- **Test Connection**: http://localhost:8000/test/

## 📋 What You'll See

### Main Dashboard Features:
1. **Statistics Cards**: Total, Active, and Resolved issues
2. **Issue Table**: All current issues with details
3. **Charts**: Visual breakdown of problem types
4. **Action Buttons**: Resolve issues with one click
5. **Status Tracking**: Color-coded urgency and status levels

### Test Page Features:
1. **Connection Test**: Verify database connectivity
2. **Sample Data**: Create test issues
3. **Data Viewing**: See all issues in your database

## 🎯 How It Works (Simple Explanation)

Think of it like this:
1. **Database (Supabase)**: Like a big filing cabinet that stores all the civic issues
2. **Django Backend**: Like a librarian that knows how to find and organize the files
3. **HTML Frontend**: Like a beautiful display window that shows the information nicely
4. **JavaScript**: Like a helper that makes the page interactive and updates data in real-time

## 🔧 Troubleshooting

### Database Connection Issues:
- ✅ Check your `.env` file has correct Supabase credentials
- ✅ Make sure your Supabase project is active
- ✅ Verify your database password is correct
- ✅ Run `python manage.py migrate` to create tables

### Common Errors:
- **"No module named 'psycopg2'"**: Run `pip install -r requirements.txt`
- **"Database connection failed"**: Check your `.env` file
- **"Table doesn't exist"**: Run `python manage.py migrate`

## 📁 Project Structure

```
departmentselection-1/
├── civic_portal/          # Main Django project
├── issues/                # Civic issues app
│   ├── models.py         # Database models
│   ├── views.py          # API endpoints
│   └── urls.py           # URL routing
├── templates/             # HTML templates
│   ├── admin_dashboard.html
│   └── test_connection.html
├── static/               # CSS, JS, images
├── requirements.txt      # Python dependencies
└── manage.py            # Django management script
```

## 🎨 Customization

### Adding New Issue Types:
Edit `issues/models.py` and add to `PROBLEM_TYPES`:
```python
PROBLEM_TYPES = [
    ('pothole', 'Pothole'),
    ('streetlight', 'Street Light'),
    ('water', 'Water Supply'),
    ('garbage', 'Garbage Collection'),
    ('traffic', 'Traffic Signal'),
    ('your_new_type', 'Your New Type'),  # Add this line
    ('other', 'Other'),
]
```

### Changing Colors:
Edit the CSS in `templates/admin_dashboard.html`:
```css
.status-pending { background-color: #your-color; }
.urgency-high { background-color: #your-color; }
```

## 🚀 Next Steps

1. **Add User Authentication**: Login system for admins
2. **Email Notifications**: Alert when issues are resolved
3. **File Upload**: Allow citizens to upload photos
4. **Mobile App**: Create a mobile version
5. **Advanced Analytics**: More detailed reporting

## 📞 Support

If you need help:
1. Check the test page: http://localhost:8000/test/
2. Look at the console for error messages
3. Verify your Supabase connection
4. Make sure all dependencies are installed

---

**🎉 Congratulations!** You now have a fully functional civic issue management system connected to Supabase!
