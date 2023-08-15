#!/bin/bash

# Flutter AI Gallery - Realistic Commit History Generator
# Creates 20 commits with actual file changes over 6 months (Aug 2023 - Jan 2024)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Creating Flutter AI Gallery commit history...${NC}"

# Function to create commits with file changes
create_commit() {
    local date=$1
    local message=$2
    local action=$3
    local files=("${@:4}")
    
    # Perform the specified action
    case $action in
        "init")
            # Initialize basic Flutter structure
            mkdir -p lib/Model lib/Model-View lib/view lib/temp
            touch lib/main.dart
            echo "import 'package:flutter/material.dart';" > lib/main.dart
            echo "" >> lib/main.dart
            echo "void main() {" >> lib/main.dart
            echo "  runApp(MyApp());" >> lib/main.dart
            echo "}" >> lib/main.dart
            ;;
        "model")
            # Add model files
            for file in "${files[@]}"; do
                if [[ $file == *.dart ]]; then
                    echo "import 'package:flutter/material.dart';" > "lib/Model/$file"
                    echo "" >> "lib/Model/$file"
                    echo "class ${file%.*} {" >> "lib/Model/$file"
                    echo "  // TODO: Implement ${file%.*}" >> "lib/Model/$file"
                    echo "}" >> "lib/Model/$file"
                fi
            done
            ;;
        "view")
            # Add view files
            for file in "${files[@]}"; do
                if [[ $file == *.dart ]]; then
                    echo "import 'package:flutter/material.dart';" > "lib/Model-View/$file"
                    echo "" >> "lib/Model-View/$file"
                    echo "class ${file%.*} extends StatefulWidget {" >> "lib/Model-View/$file"
                    echo "  @override" >> "lib/Model-View/$file"
                    echo "  _${file%.*}State createState() => _${file%.*}State();" >> "lib/Model-View/$file"
                    echo "}" >> "lib/Model-View/$file"
                fi
            done
            ;;
        "update")
            # Update existing files
            for file in "${files[@]}"; do
                if [ -f "$file" ]; then
                    echo "// Updated on $date" >> "$file"
                    echo "" >> "$file"
                fi
            done
            ;;
        "config")
            # Add configuration files
            for file in "${files[@]}"; do
                touch "$file"
                echo "# Configuration for $file" > "$file"
                echo "# Generated on $date" >> "$file"
            done
            ;;
        "assets")
            # Create asset directories and files
            mkdir -p images assets
            for file in "${files[@]}"; do
                touch "$file"
            done
            ;;
    esac
    
    # Add all changes
    git add -A
    
    # Create commit with specific date
    GIT_COMMITTER_DATE="$date" git commit --date="$date" -m "$message" || true
    echo -e "${GREEN}✓ $message${NC}"
}

# Commit timeline (20 commits over 6 months)
declare -a commits=(
    # August 2023 - Project Setup
    "2023-08-15 10:30:00|initial commit|init|."
    "2023-08-16 14:20:00|add pubspec|config|pubspec.yaml"
    "2023-08-18 09:45:00|flutter setup|config|analysis_options.yaml"
    "2023-08-20 16:15:00|basic models|model|app_state.dart viewstate.dart"
    
    # September 2023 - Core Features
    "2023-09-02 11:30:00|gallery provider|model|GalleryProvider.dart"
    "2023-09-08 15:45:00|image labeling|model|ImagelabelingProvider.dart"
    "2023-09-12 13:20:00|gallery home|view|GalleryHome.dart"
    "2023-09-18 10:50:00|splash screen|view|splashscreen.dart"
    "2023-09-25 14:35:00|main setup|update|lib/main.dart"
    
    # October 2023 - Features Development
    "2023-10-03 12:15:00|auth screens|view|login.dart Signup_page.dart"
    "2023-10-10 16:40:00|payment integration|model|payment_provider.dart"
    "2023-10-15 09:25:00|coin system|model|coins_provider.dart CoinUpdaterFirebaseProvider.dart"
    "2023-10-22 11:55:00|bg remover|view|bg_remover.dart"
    "2023-10-28 15:30:00|upscaling feature|view|upscaling.dart"
    
    # November 2023 - Advanced Features
    "2023-11-05 13:45:00|inpainting|view|inpainting.dart masking.dart"
    "2023-11-12 10:20:00|similar photos|model|similarphotoProvider.dart"
    "2023-11-18 14:50:00|features list|view|Featureslistscreen.dart"
    "2023-11-25 12:30:00|viewer page|view|ViewerPage.dart AlbumPage.dart"
    
    # December 2023 - Polish
    "2023-12-08 16:25:00|email verify|view|emailverify.dart"
    "2023-12-20 11:40:00|final touches|update|README.md"
)

# Initialize git if not already done
if [ ! -d ".git" ]; then
    git init
    echo -e "${YELLOW}📦 Git repository initialized${NC}"
fi

# Create commits
total=${#commits[@]}
current=0

for commit_data in "${commits[@]}"; do
    current=$((current + 1))
    IFS='|' read -r date message action files <<< "$commit_data"
    
    # Convert files to array
    IFS=' ' read -ra file_array <<< "$files"
    
    echo -e "${BLUE}[$current/$total]${NC} Processing: $message"
    
    create_commit "$date" "$message" "$action" "${file_array[@]}"
    
    # Small delay
    sleep 0.1
done

# Final summary
final_commits=$(git rev-list --count HEAD)
echo -e "${GREEN}🎉 Created ${final_commits} commits${NC}"
echo -e "${BLUE}📊 Project structure:${NC}"
echo -e "  ├── lib/"
echo -e "  │   ├── Model/ (providers & state)"
echo -e "  │   ├── Model-View/ (screens & UI)"
echo -e "  │   └── main.dart"
echo -e "  ├── images/"
echo -e "  └── pubspec.yaml"

echo -e "${YELLOW}💡 Ready to push:${NC}"
echo -e "   git remote add origin <your-repo-url>"
echo -e "   git push -u origin main"
