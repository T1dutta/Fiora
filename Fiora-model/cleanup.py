"""
Cleanup script to remove frontend and blockchain directories
Run this script to complete the removal process
"""
import shutil
import os

def remove_directory(path, name):
    """Attempt to remove a directory"""
    if os.path.exists(path):
        try:
            shutil.rmtree(path)
            print(f"✅ Successfully removed {name} directory")
            return True
        except PermissionError:
            print(f"❌ Permission denied to remove {name}")
            print(f"   Please manually delete: {path}")
            return False
        except Exception as e:
            print(f"❌ Error removing {name}: {e}")
            print(f"   Please manually delete: {path}")
            return False
    else:
        print(f"ℹ️  {name} directory doesn't exist (may already be removed)")
        return True

def main():
    project_root = os.path.dirname(os.path.abspath(__file__))
    
    print("=" * 60)
    print("Shakti AI - Cleanup Script")
    print("Removing frontend and blockchain components...")
    print("=" * 60)
    
    # Remove frontend
    frontend_path = os.path.join(project_root, "frontend")
    remove_directory(frontend_path, "frontend")
    
    # Remove blockchain
    blockchain_path = os.path.join(project_root, "blockchain")
    remove_directory(blockchain_path, "blockchain")
    
    print("\n" + "=" * 60)
    print("Cleanup complete!")
    print("=" * 60)
    print("\nNext steps:")
    print("1. If any directories couldn't be removed, delete them manually")
    print("2. Run: pip install -r requirements.txt")
    print("3. Your AI/ML models are preserved in the 'ai/' directory")

if __name__ == "__main__":
    main()
