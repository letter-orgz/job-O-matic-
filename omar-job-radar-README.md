# Omar's Job Radar 🎯

A comprehensive single-page application for job search and application management, specifically designed for Omar's job search needs.

## 🌟 Features

### 📊 Data Management
- **Multiple Input Methods**: JSON paste, file uploads, GitHub URL fetching, and Perplexity API integration
- **Automatic Deduplication**: Uses `apply_url` as primary key to prevent duplicate entries
- **Track Categorization**: Automatically categorizes jobs into "Legal" or "Gigs" tracks
- **Sample Data**: Loads with 3 realistic sample jobs (2 Legal track, 1 Gigs) for immediate testing

### 🔍 Advanced Filtering
- **Free-text Search**: Search across job titles, companies, and descriptions
- **Multi-dimensional Filters**: Track type, work mode, contract type, seniority level
- **Date Range Filtering**: Filter jobs by posting date
- **Remote-only Toggle**: Quick filter for remote-only positions
- **Real-time Results**: Instant filtering with smooth animations

### 📱 Responsive Design
- **Desktop Table View**: Comprehensive table with all job details
- **Mobile Card View**: Optimized card layout for mobile devices
- **Automatic Adaptation**: Seamlessly switches between layouts based on screen size
- **Touch-friendly**: All interactions optimized for mobile use

### 💼 Job Management
- **Starring System**: Mark favorite jobs with a simple click
- **Personal Notes**: Add and edit notes for each job opportunity
- **Cover Letter Outline**: Personalized application guidance based on job details and Omar's profile
- **Quick Actions**: Easy access to apply links, notes, and cover letter help

### 💾 Persistence & State Management
- **localStorage Integration**: All data automatically saved locally
- **Filter Preferences**: Remember search and filter settings between sessions
- **State Export/Import**: Save and load complete application states as JSON
- **No External Dependencies**: Runs entirely client-side for privacy and speed

### 📈 Bulk Operations
- **Multi-select**: Select individual jobs or use "Select All" functionality
- **Bulk Starring**: Star or unstar multiple jobs at once
- **Export Options**: Export filtered or selected jobs to CSV or JSON formats
- **Bulk Actions Panel**: Dedicated interface for managing multiple jobs efficiently

## 🚀 Getting Started

### Option 1: Direct File Access
1. Open `index.html` directly in any modern web browser
2. The application loads immediately with sample data
3. Start exploring features or import your own job data

### Option 2: Local Server (Recommended)
```bash
# Start a simple HTTP server
python -m http.server 8080

# Or use Node.js
npx http-server -p 8080

# Then visit http://localhost:8080/index.html
```

## 📋 Usage Guide

### Getting Started
1. **First Load**: The app loads with 3 sample jobs to demonstrate functionality
2. **Import Data**: Use any of the data import methods to add your own jobs
3. **Explore Filtering**: Try different filters to find jobs that match your criteria
4. **Manage Jobs**: Star favorites, add notes, and view cover letter guidance

### Data Import Methods
- **JSON Paste**: Copy job data in JSON format and paste directly
- **File Upload**: Import JSON or CSV files containing job data
- **GitHub Integration**: Fetch job data from GitHub repositories (demo mode)
- **Perplexity Search**: Search for jobs using AI (demo mode)

### Job Management Workflow
1. **Browse & Filter**: Use filters to find relevant opportunities
2. **Star Favorites**: Mark interesting jobs for easy reference
3. **Add Notes**: Record thoughts, application status, or follow-up actions
4. **Cover Letter Help**: Get personalized application guidance for each job
5. **Apply**: Use direct links to job application pages

### Export & Backup
- **Export Filtered**: Export current search results to CSV or JSON
- **Export Selected**: Export only checked jobs
- **Save State**: Backup complete application state including notes and stars
- **Load State**: Restore previous application state from backup file

## 🎯 Key Benefits for Omar

### Legal Track Focus
- Pre-configured with legal industry job types
- Personalized cover letter guidance for legal positions
- Salary context and market insights
- Practice area categorization

### Gigs & Freelance Support
- Separate track for freelance and project-based work
- Hourly rate tracking
- Flexible work arrangement filtering
- Project-focused application guidance

### Privacy & Control
- No external data sharing
- Complete local control of job data
- Secure localStorage persistence
- Self-contained application (no cloud dependencies)

### Efficiency Features
- Bulk operations for managing large job lists
- Instant filtering and search
- Keyboard-friendly interface
- Mobile-optimized for job searching on the go

## 🛠 Technical Details

### Technology Stack
- **Frontend**: Pure HTML5, CSS3, and JavaScript
- **Storage**: Browser localStorage API
- **Design**: Responsive CSS Grid and Flexbox
- **UI/UX**: Professional gradient design with smooth animations
- **Compatibility**: Works in all modern browsers (Chrome, Firefox, Safari, Edge)

### Data Structure
Each job contains:
- Unique ID and deduplication key (apply_url)
- Company and position details
- Location and work arrangement info
- Track categorization (Legal/Gigs)
- Contract type and seniority level
- Salary/rate information
- Personal annotations (starred, notes)

### Browser Compatibility
- Chrome 80+ ✅
- Firefox 75+ ✅
- Safari 13+ ✅
- Edge 80+ ✅
- Mobile browsers ✅

## 📱 Mobile Features

### Optimized Mobile Experience
- Touch-friendly buttons and controls
- Swipe-friendly card interface
- Responsive text sizing
- Mobile-optimized modals and forms
- One-handed operation support

### Mobile-Specific Features
- Card layout automatically activates on mobile
- Touch-optimized filter controls
- Mobile-friendly date pickers
- Responsive statistics cards
- Mobile-optimized bulk actions

## 🔒 Privacy & Security

### Data Privacy
- All data stored locally in browser
- No external API calls for core functionality
- No user tracking or analytics
- Complete control over personal job data

### Security Features
- No external dependencies for core features
- Client-side data processing only
- Secure localStorage implementation
- No sensitive data transmission

## 📄 Sample Data

The application includes three realistic sample jobs:

1. **Clifford Chance** - Senior Legal Counsel (Technology)
   - Legal track, Hybrid work, £120-150k
   - Demonstrates high-level legal position

2. **Magic Circle Firm** - Corporate Associate
   - Legal track, On-site, £85-110k
   - Shows mid-level progression opportunity
   - Pre-starred with sample notes

3. **LegalTech Startup** - Freelance Legal Content Writer
   - Gigs track, Remote, £50-80/hour
   - Examples freelance/project work

## 🎨 Design Philosophy

### User-Centered Design
- Clean, professional interface suitable for job searching
- Intuitive navigation and clear information hierarchy
- Consistent visual language throughout
- Accessibility-focused design patterns

### Responsive-First Approach
- Mobile-first design methodology
- Progressive enhancement for larger screens
- Touch and mouse interaction support
- Flexible layouts that adapt to any screen size

### Performance Optimization
- Instant loading and response times
- Smooth animations and transitions
- Efficient filtering and search algorithms
- Minimal resource usage

---

**Created specifically for Omar's job search and career management needs.**
**Version 1.0 - Single-page application with comprehensive job management features.**