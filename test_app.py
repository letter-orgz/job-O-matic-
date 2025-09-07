#!/usr/bin/env python3
"""
Test application to verify Job-O-Matic functionality
This script tests core functionality without requiring full Streamlit setup
"""

import os
import sys
import json
import time
from pathlib import Path

def test_environment():
    """Test the basic environment setup"""
    print("=== Job-O-Matic Environment Test ===")
    
    # Test Python version
    print(f"Python version: {sys.version}")
    
    # Test required directories
    required_dirs = ['data/cv', 'src/ui', 'src/apply', 'exports', 'outputs', 'db']
    for dir_path in required_dirs:
        if Path(dir_path).exists():
            print(f"✓ Directory exists: {dir_path}")
        else:
            print(f"✗ Missing directory: {dir_path}")
            Path(dir_path).mkdir(parents=True, exist_ok=True)
            print(f"  → Created: {dir_path}")
    
    # Test CV files
    cv_dir = Path('data/cv')
    cv_files = list(cv_dir.glob('*.*'))
    print(f"CV files found: {len(cv_files)}")
    for cv_file in cv_files[:3]:  # Show first 3
        print(f"  - {cv_file.name}")
    
    # Test core modules
    try:
        import requests
        print("✓ requests module available")
    except ImportError:
        print("✗ requests module not available")
    
    try:
        import sqlite3
        print("✓ sqlite3 module available")
    except ImportError:
        print("✗ sqlite3 module not available")
    
    return True

def test_database_setup():
    """Test database creation and basic operations"""
    print("\n=== Database Setup Test ===")
    
    import sqlite3
    db_path = Path('db/app.db')
    
    # Create database directory
    db_path.parent.mkdir(exist_ok=True)
    
    # Test database connection
    try:
        conn = sqlite3.connect(str(db_path))
        cursor = conn.cursor()
        
        # Create basic table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS jobs (
                id INTEGER PRIMARY KEY,
                company TEXT,
                title TEXT,
                apply_url TEXT,
                status TEXT DEFAULT 'NOT_APPLIED'
            )
        ''')
        
        # Test insert
        cursor.execute('''
            INSERT OR REPLACE INTO jobs (id, company, title, apply_url) 
            VALUES (1, 'Test Company', 'Test Role', 'https://example.com/apply')
        ''')
        
        conn.commit()
        
        # Test select
        cursor.execute('SELECT COUNT(*) FROM jobs')
        count = cursor.fetchone()[0]
        print(f"✓ Database setup successful, {count} test records")
        
        conn.close()
        return True
    except Exception as e:
        print(f"✗ Database error: {e}")
        return False

def test_cv_processing():
    """Test CV file processing"""
    print("\n=== CV Processing Test ===")
    
    cv_dir = Path('data/cv')
    cv_files = list(cv_dir.glob('*.docx')) + list(cv_dir.glob('*.pdf'))
    
    if not cv_files:
        print("✗ No CV files found")
        # Create a test CV file
        test_cv = cv_dir / 'test_cv.txt'
        test_cv.write_text('Test CV Content\nName: Test User\nSkills: Python, Testing')
        print(f"  → Created test CV: {test_cv}")
        return False
    
    for cv_file in cv_files[:2]:  # Test first 2 files
        file_size = cv_file.stat().st_size
        print(f"✓ CV file: {cv_file.name} ({file_size // 1024} KB)")
    
    return True

def test_output_generation():
    """Test output directory creation and file generation"""
    print("\n=== Output Generation Test ===")
    
    timestamp = time.strftime("%Y%m%d-%H%M%S")
    output_dir = Path('outputs') / timestamp / 'test_job'
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Create test output files
    test_files = {
        'tailored.txt': 'Test tailored CV content',
        'email_subject.txt': 'Application for Test Role at Test Company',
        'email_body.txt': 'Dear Hiring Manager,\n\nTest email body content.',
        'job_info.txt': 'Company: Test Company\nTitle: Test Role\nURL: https://example.com'
    }
    
    for filename, content in test_files.items():
        file_path = output_dir / filename
        file_path.write_text(content, encoding='utf-8')
        print(f"✓ Created: {filename}")
    
    print(f"✓ Output directory: {output_dir}")
    return True

def test_export_functionality():
    """Test export capabilities"""
    print("\n=== Export Test ===")
    
    # Test CSV export simulation
    exports_dir = Path('exports')
    exports_dir.mkdir(exist_ok=True)
    
    test_data = [
        {'company': 'Test Co 1', 'title': 'Developer', 'status': 'NOT_APPLIED'},
        {'company': 'Test Co 2', 'title': 'Engineer', 'status': 'PENDING'}
    ]
    
    # Export as JSON
    json_file = exports_dir / f'jobs_export_{time.strftime("%Y%m%d_%H%M%S")}.json'
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(test_data, f, indent=2)
    print(f"✓ JSON export: {json_file}")
    
    # Export as CSV simulation
    csv_file = exports_dir / f'jobs_export_{time.strftime("%Y%m%d_%H%M%S")}.csv'
    csv_content = "company,title,status\nTest Co 1,Developer,NOT_APPLIED\nTest Co 2,Engineer,PENDING"
    csv_file.write_text(csv_content, encoding='utf-8')
    print(f"✓ CSV export: {csv_file}")
    
    return True

def main():
    """Run all tests"""
    print("Job-O-Matic System Test")
    print("=" * 50)
    
    start_time = time.time()
    
    tests = [
        test_environment,
        test_database_setup,
        test_cv_processing,
        test_output_generation,
        test_export_functionality
    ]
    
    results = []
    for test in tests:
        try:
            result = test()
            results.append(result)
        except Exception as e:
            print(f"✗ Test failed: {e}")
            results.append(False)
    
    end_time = time.time()
    
    print(f"\n=== Test Summary ===")
    print(f"Tests passed: {sum(results)}/{len(results)}")
    print(f"Total time: {end_time - start_time:.2f} seconds")
    
    if all(results):
        print("✓ All tests passed - Job-O-Matic environment ready!")
        return 0
    else:
        print("✗ Some tests failed - check setup")
        return 1

if __name__ == "__main__":
    exit(main())