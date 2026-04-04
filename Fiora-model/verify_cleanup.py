"""
Verification script - Check that blockchain and frontend references are removed
"""
import os
import re

def check_file_for_patterns(filepath, patterns):
    """Check if file contains any of the given patterns"""
    issues = []
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            for pattern_name, pattern in patterns.items():
                if re.search(pattern, content):
                    issues.append(f"  - Found '{pattern_name}' in {filepath}")
    except Exception as e:
        issues.append(f"  - Error reading {filepath}: {e}")
    return issues

def main():
    print("=" * 70)
    print("Shakti AI - Verification Script")
    print("Checking for blockchain and frontend references...")
    print("=" * 70)
    
    # Patterns to check for
    patterns = {
        'blockchain import': r'from blockchain',
        'check_consent call': r'check_consent\(',
        'StaticFiles': r'StaticFiles',
        'FileResponse': r'FileResponse',
        'FRONTEND_URL': r'FRONTEND_URL',
        'py-algorand-sdk': r'py-algorand-sdk',
    }
    
    # Files to check
    files_to_check = [
        'main.py',
        'requirements.txt',
    ]
    
    all_issues = []
    for filename in files_to_check:
        if os.path.exists(filename):
            issues = check_file_for_patterns(filename, patterns)
            all_issues.extend(issues)
    
    # Check if directories still exist
    print("\n[Directory Check]")
    if os.path.exists('frontend'):
        print("  WARNING: 'frontend' directory still exists - please delete manually")
        all_issues.append("Frontend directory exists")
    else:
        print("  OK: 'frontend' directory removed")
    
    if os.path.exists('blockchain'):
        print("  WARNING: 'blockchain' directory still exists - please delete manually")
        all_issues.append("Blockchain directory exists")
    else:
        print("  OK: 'blockchain' directory removed")
    
    # Check AI components are intact
    print("\n[AI/ML Components Check]")
    ai_components = [
        'ai/engine.py',
        'ai/rag.py',
        'ai/voice.py',
        'ai/endometriosis_model.py',
        'ai/pcos_model.py',
    ]
    
    missing_ai = []
    for component in ai_components:
        if os.path.exists(component):
            print(f"  OK: {component} present")
        else:
            print(f"  ERROR: {component} missing!")
            missing_ai.append(component)
    
    # Final report
    print("\n" + "=" * 70)
    if all_issues or missing_ai:
        print("VERIFICATION FAILED")
        print("=" * 70)
        if all_issues:
            print("\nIssues found:")
            for issue in all_issues:
                print(issue)
        if missing_ai:
            print("\nMissing AI components:")
            for component in missing_ai:
                print(f"  - {component}")
    else:
        print("VERIFICATION PASSED")
        print("=" * 70)
        print("\nAll blockchain and frontend references removed successfully!")
        print("All AI/ML components are intact.")
        print("\nNext steps:")
        print("1. Delete 'frontend' and 'blockchain' folders if they still exist")
        print("2. Run: pip install -r requirements.txt")
        print("3. Start server: python -m uvicorn main:app --reload")

if __name__ == "__main__":
    main()
