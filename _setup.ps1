# Update blog from latest upstream version
# See _update-blog.md
# Vars
$oldBlogPath = "C:\Users\adamr\Code\adamrushuk.github.io"
$newBlogPath = "C:\Users\adamr\Code\minimal-mistakes"

# Ensure in new blog repo root
Set-Location $newBlogPath

# Cleanup (Remove unwanted files)
$pathsToRemove = @(
    ".editorconfig"
    ".gitattributes"
    ".github"
    "docs"
    "test"
    "CHANGELOG.md"
    "minimal-mistakes-jekyll.gemspec"
    # "README.md"
    "screenshot-layouts.png"
    "screenshot.png"
)
Remove-Item -Path $pathsToRemove -Force -Recurse -Verbose #-WhatIf

# Copy files from old blog
$filesToCopy = @(
    "_cheatsheets"
    "_pages"
    "_posts"
    "_setup.ps1"
    ".dockerignore"
    "404.md"
    "category-archive.md"
    "docker-build.ps1"
    "docker-compose.yml"
    "Dockerfile"
    "favicon.ico"
    "Gemfile"
    "tag-archive.md"
)
foreach ($fileToCopy in $filesToCopy) {
    $fullFilePath = Join-Path -Path $oldBlogPath -ChildPath $fileToCopy
    Copy-Item -Path $fullFilePath -Destination $newBlogPath -Force -Recurse -Verbose #-WhatIf
}

# Copy images
$imageSourcePath = Join-Path -Path $oldBlogPath -ChildPath "assets/images"
$imagesDestPath = Join-Path -Path $newBlogPath -ChildPath "assets/images"
Copy-Item -Path $imageSourcePath -Destination $imagesDestPath -Force -Recurse -Verbose #-WhatIf

# Manual steps
<#
Add the following to the code styling (after pre {} ~ line 163)
color: #c7254e;
background-color: #f9f2f4;
#>
