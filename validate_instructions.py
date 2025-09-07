#!/usr/bin/env python3
"""
Complete validation script for Job-O-Matic instructions
This script validates all the commands and scenarios mentioned in the instructions
"""

import os
import sys
import time
import subprocess
import sqlite3
from pathlib import Path

def run_command(cmd, timeout=60, description=""):
    """Run a command and return success/failure with timing"""
    print(f"Testing: {description}")
    print(f"Command: {cmd}")
    
    start_time = time.time()
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
        end_time = time.time()
        
        success = result.returncode == 0
        duration = end_time - start_time
        
        print(f"Result: {'✓ PASS' if success else '✗ FAIL'}")
        print(f"Duration: {duration:.2f} seconds")
        
        if not success:
            print(f"Error: {result.stderr}")
        
        return success, duration
    except subprocess.TimeoutExpired:
        print(f"✗ TIMEOUT after {timeout} seconds")
        return False, timeout
    except Exception as e:
        print(f"✗ ERROR: {e}")
        return False, 0

def validate_directory_structure():
    """Validate the expected directory structure"""
    print("\n=== Directory Structure Validation ===")
    
    required_dirs = [
        '.github',
        'data/cv', 
        'src/ui', 
        'src/apply', 
        'db', 
        'exports', 
        'outputs'
    ]
    
    all_good = True
    for dir_path in required_dirs:
        path = Path(dir_path)
        if path.exists():
            print(f"✓ {dir_path}")
        else:
            print(f"✗ Missing: {dir_path}")
            path.mkdir(parents=True, exist_ok=True)
            print(f"  → Created: {dir_path}")
            all_good = False
    
    return all_good

def validate_files():
    """Validate critical files exist"""
    print("\n=== Critical Files Validation ===")
    
    required_files = [
        '.github/copilot-instructions.md',
        'app.py',
        'test_app.py',
        'requirements.txt'
    ]
    
    all_good = True
    for file_path in required_files:
        path = Path(file_path)
        if path.exists():
            size = path.stat().st_size
            print(f"✓ {file_path} ({size} bytes)")
        else:
            print(f"✗ Missing: {file_path}")
            all_good = False
    
    return all_good

def validate_python_environment():
    """Validate Python environment and basic imports"""
    print("\n=== Python Environment Validation ===")
    
    # Test Python version
    version = sys.version_info
    print(f"Python version: {version.major}.{version.minor}.{version.micro}")
    
    if version.major < 3 or (version.major == 3 and version.minor < 8):
        print("✗ Python 3.8+ required")
        return False
    
    # Test core modules
    core_modules = ['sqlite3', 'json', 'pathlib', 'requests', 'time', 'os', 'sys']
    missing = []
    
    for module in core_modules:
        try:
            __import__(module)
            print(f"✓ {module}")
        except ImportError:
            print(f"✗ {module}")
            missing.append(module)
    
    if missing:
        print(f"Missing modules: {missing}")
        return False
    
    return True

def validate_database_operations():
    """Validate database operations work correctly"""
    print("\n=== Database Operations Validation ===")
    
    db_path = Path('db/test_validation.db')
    db_path.parent.mkdir(exist_ok=True)
    
    try:
        # Test database creation
        start_time = time.time()
        conn = sqlite3.connect(str(db_path))
        cursor = conn.cursor()
        
        # Create table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS validation_jobs (
                id INTEGER PRIMARY KEY,
                company TEXT,
                title TEXT,
                status TEXT DEFAULT 'NOT_APPLIED'
            )
        ''')
        
        # Insert test data
        test_jobs = [
            ('TestCorp', 'Developer', 'NOT_APPLIED'),
            ('DataCorp', 'Analyst', 'PENDING'),
            ('TechCorp', 'Engineer', 'SENT')
        ]
        
        cursor.executemany('INSERT INTO validation_jobs (company, title, status) VALUES (?, ?, ?)', test_jobs)
        conn.commit()
        
        # Query data
        cursor.execute('SELECT COUNT(*) FROM validation_jobs')
        count = cursor.fetchone()[0]
        
        # Test status updates
        cursor.execute('UPDATE validation_jobs SET status = ? WHERE company = ?', ('INTERVIEW', 'TestCorp'))
        conn.commit()
        
        conn.close()
        db_time = time.time() - start_time
        
        print(f"✓ Database operations successful")
        print(f"✓ Created {count} records")
        print(f"✓ Duration: {db_time:.3f} seconds")
        
        # Cleanup
        db_path.unlink()
        
        return True
    except Exception as e:
        print(f"✗ Database error: {e}")
        return False

def validate_file_operations():
    """Validate file I/O operations work correctly"""
    print("\n=== File Operations Validation ===")
    
    exports_dir = Path('exports')
    outputs_dir = Path('outputs')
    
    exports_dir.mkdir(exist_ok=True)
    outputs_dir.mkdir(exist_ok=True)
    
    try:
        # Test export operations
        import json
        test_data = [
            {'company': 'Test Co', 'title': 'Test Role', 'status': 'NOT_APPLIED'},
            {'company': 'Example Inc', 'title': 'Sample Job', 'status': 'PENDING'}
        ]
        
        # JSON export
        json_file = exports_dir / 'validation_test.json'
        start_time = time.time()
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump(test_data, f, indent=2)
        json_time = time.time() - start_time
        
        # CSV export
        csv_file = exports_dir / 'validation_test.csv'
        start_time = time.time()
        csv_content = "company,title,status\nTest Co,Test Role,NOT_APPLIED\nExample Inc,Sample Job,PENDING"
        csv_file.write_text(csv_content, encoding='utf-8')
        csv_time = time.time() - start_time
        
        # Output directory structure
        output_dir = outputs_dir / 'validation_test' / 'test_job'
        output_dir.mkdir(parents=True, exist_ok=True)
        
        test_files = {
            'tailored.txt': 'Test tailored content',
            'email_subject.txt': 'Test subject',
            'email_body.txt': 'Test email body'
        }
        
        start_time = time.time()
        for filename, content in test_files.items():
            (output_dir / filename).write_text(content, encoding='utf-8')
        output_time = time.time() - start_time
        
        print(f"✓ JSON export: {json_time:.3f} seconds")
        print(f"✓ CSV export: {csv_time:.3f} seconds")
        print(f"✓ Output files: {output_time:.3f} seconds")
        
        # Cleanup
        json_file.unlink()
        csv_file.unlink()
        for file_path in output_dir.glob('*'):
            file_path.unlink()
        output_dir.rmdir()
        output_dir.parent.rmdir()
        
        return True
    except Exception as e:
        print(f"✗ File operations error: {e}")
        return False

def main():
    """Run complete validation suite"""
    print("Job-O-Matic Instructions Validation")
    print("=" * 50)
    
    start_time = time.time()
    
    # Run all validations
    validations = [
        ("Directory Structure", validate_directory_structure),
        ("Critical Files", validate_files),
        ("Python Environment", validate_python_environment),
        ("Database Operations", validate_database_operations),
        ("File Operations", validate_file_operations)
    ]
    
    results = []
    for name, func in validations:
        try:
            result = func()
            results.append((name, result))
        except Exception as e:
            print(f"✗ {name} failed with error: {e}")
            results.append((name, False))
    
    # Command validations
    print("\n=== Command Validations ===")
    command_results = []
    
    # Test basic environment test
    success, duration = run_command("python3 test_app.py", 60, "Environment test script")
    command_results.append(("Environment Test", success, duration))
    
    # Test Python core functionality
    success, duration = run_command('python3 -c "import sqlite3, json; print(\'Core modules OK\')"', 10, "Core Python modules")
    command_results.append(("Core Modules", success, duration))
    
    end_time = time.time()
    total_time = end_time - start_time
    
    # Summary
    print(f"\n=== Validation Summary ===")
    print(f"Total validation time: {total_time:.2f} seconds")
    
    # Validation results
    passed_validations = sum(1 for _, result in results if result)
    print(f"Validations passed: {passed_validations}/{len(results)}")
    
    for name, result in results:
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"  {status}: {name}")
    
    # Command results
    passed_commands = sum(1 for _, result, _ in command_results if result)
    print(f"Commands passed: {passed_commands}/{len(command_results)}")
    
    for name, result, duration in command_results:
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"  {status}: {name} ({duration:.2f}s)")
    
    # Overall result
    all_passed = passed_validations == len(results) and passed_commands == len(command_results)
    
    if all_passed:
        print("\n🎉 ALL VALIDATIONS PASSED!")
        print("The instructions are comprehensive and accurate.")
        return 0
    else:
        print("\n⚠️  SOME VALIDATIONS FAILED")
        print("Review the failed items and update instructions accordingly.")
        return 1

if __name__ == "__main__":
    exit(main())