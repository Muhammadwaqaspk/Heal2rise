#!/usr/bin/env python3
"""
Auto File Organizer
==================
Automatically organizes files in a directory by their extensions.
Created for learning automation and file handling concepts.

Author: [Muhammad Waqas]
Date: Jan 2026
"""

import os
import shutil
from pathlib import Path
from collections import defaultdict
import argparse
from datetime import datetime


class FileOrganizer:
    """
    A simple automation tool to organize messy directories.
    Demonstrates: OOP, file handling, error handling, CLI arguments
    """
    
    # File type categories
    CATEGORIES = {
        'Images': ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg', '.webp'],
        'Documents': ['.pdf', '.doc', '.docx', '.txt', '.rtf', '.odt', '.xls', '.xlsx', '.ppt', '.pptx'],
        'Videos': ['.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm'],
        'Audio': ['.mp3', '.wav', '.flac', '.aac', '.ogg', '.wma', '.m4a'],
        'Archives': ['.zip', '.rar', '.7z', '.tar', '.gz', '.bz2'],
        'Code': ['.py', '.js', '.html', '.css', '.java', '.cpp', '.c', '.h', '.php', '.rb', '.go', '.rs'],
        'Executables': ['.exe', '.msi', '.dmg', '.pkg', '.deb', '.rpm', '.appimage']
    }
    
    def __init__(self, source_dir, dry_run=False):
        self.source_dir = Path(source_dir).expanduser().resolve()
        self.dry_run = dry_run  # Preview mode without moving files
        self.stats = defaultdict(int)
        self.log_file = self.source_dir / f"organizer_log_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
        
    def _get_category(self, extension):
        """Determine file category based on extension."""
        ext_lower = extension.lower()
        for category, extensions in self.CATEGORIES.items():
            if ext_lower in extensions:
                return category
        return 'Others'
    
    def _organize_file(self, file_path):
        """Organize a single file."""
        extension = file_path.suffix
        category = self._get_category(extension)
        
        # Create category folder
        target_dir = self.source_dir / category
        target_dir.mkdir(exist_ok=True)
        
        # Handle duplicate filenames
        target_file = target_dir / file_path.name
        counter = 1
        original_target = target_file
        while target_file.exists() and not self.dry_run:
            stem = original_target.stem
            suffix = original_target.suffix
            target_file = target_dir / f"{stem}_{counter}{suffix}"
            counter += 1
        
        # Move or preview
        if self.dry_run:
            action = "WOULD MOVE"
        else:
            try:
                shutil.move(str(file_path), str(target_file))
                action = "MOVED"
            except Exception as e:
                action = f"ERROR: {e}"
        
        self.stats[category] += 1
        return f"{action}: {file_path.name} -> {category}/"
    
    def organize(self):
        """Main organization logic."""
        if not self.source_dir.exists():
            print(f"❌ Directory not found: {self.source_dir}")
            return False
        
        print(f"\n📁 Scanning: {self.source_dir}")
        print(f"🔍 Mode: {'DRY RUN (Preview Only)' if self.dry_run else 'LIVE'}\n")
        
        files_to_organize = [f for f in self.source_dir.iterdir() if f.is_file()]
        
        if not files_to_organize:
            print("ℹ️  No files to organize!")
            return True
        
        # Process files
        log_entries = []
        for file_path in files_to_organize:
            # Skip the script itself and log files
            if file_path.name == __file__ or 'organizer_log' in file_path.name:
                continue
            
            result = self._organize_file(file_path)
            print(f"  {result}")
            log_entries.append(result)
        
        # Save log
        if not self.dry_run:
            with open(self.log_file, 'w') as f:
                f.write(f"Auto File Organizer Log\n")
                f.write(f"Date: {datetime.now()}\n")
                f.write(f"Source: {self.source_dir}\n")
                f.write("-" * 50 + "\n")
                f.write("\n".join(log_entries))
        
        # Print summary
        self._print_summary()
        return True
    
    def _print_summary(self):
        """Display organization statistics."""
        print(f"\n{'='*50}")
        print("📊 ORGANIZATION SUMMARY")
        print(f"{'='*50}")
        total = sum(self.stats.values())
        for category, count in sorted(self.stats.items()):
            print(f"  📂 {category:15} : {count:3} files")
        print(f"{'-'*50}")
        print(f"  📦 Total: {total} files")
        if not self.dry_run:
            print(f"  📝 Log saved: {self.log_file.name}")
        print(f"{'='*50}\n")


def main():
    """CLI entry point with argument parsing."""
    parser = argparse.ArgumentParser(
        description="Auto File Organizer - Organize your messy folders!",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python auto_organizer.py ~/Downloads          # Organize Downloads
  python auto_organizer.py . --dry-run          # Preview current directory
  python auto_organizer.py /path/to/folder      # Organize specific folder
        """
    )
    parser.add_argument(
        'directory',
        nargs='?',
        default='.',
        help='Directory to organize (default: current directory)'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Preview changes without moving files'
    )
    
    args = parser.parse_args()
    
    # Create organizer instance
    organizer = FileOrganizer(args.directory, dry_run=args.dry_run)
    
    # Run organization
    success = organizer.organize()
    
    return 0 if success else 1


if __name__ == "__main__":
    exit(main())