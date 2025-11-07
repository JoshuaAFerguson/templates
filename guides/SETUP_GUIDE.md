# Quick Wins Setup Guide

This guide walks you through setting up your professional GitHub templates and portfolio site.

## 1. Professional README Template

### Usage

The README template is located at `templates/README.template.md`.

**To use it for a new repository:**

```bash
# Navigate to your repository
cd ~/path/to/your-repo

# Copy the template
cp ~/dotfiles/templates/README.template.md README.md

# Edit and customize
vim README.md
# Replace PROJECT-NAME, descriptions, features, etc.
```

**Customization checklist:**
- [ ] Replace `PROJECT-NAME` with your actual project name
- [ ] Update project description
- [ ] List actual features
- [ ] Update prerequisites
- [ ] Add installation instructions
- [ ] Include usage examples
- [ ] Update architecture diagrams
- [ ] Add contact information
- [ ] Customize sections based on project type

## 2. GitHub Profile README

### Setup

GitHub displays a special README on your profile page if you create a repository with the same name as your username.

**Step 1: Create the repository**

```bash
# Using GitHub CLI
gh repo create JoshuaAFerguson --public --clone

# Or via web: https://github.com/new
# Repository name: JoshuaAFerguson
# Description: Special repository for GitHub profile
# Visibility: Public
# Initialize with README: ✅
```

**Step 2: Add the profile README**

```bash
# Navigate to the repository
cd JoshuaAFerguson

# Copy the template
cp ~/dotfiles/templates/PROFILE_README.md README.md

# Customize it
vim README.md
```

**Step 3: Customize**

Edit `README.md` and update:
- [ ] LinkedIn URL (replace `your-profile`)
- [ ] Twitter handle (if applicable, or remove section)
- [ ] Portfolio URL
- [ ] Current projects and focus areas
- [ ] Blog posts section
- [ ] Skills and technologies
- [ ] Featured projects (ensure links are correct)

**Step 4: Push changes**

```bash
git add README.md
git commit -m "Add GitHub profile README"
git push
```

**Step 5: Verify**

Visit https://github.com/JoshuaAFerguson to see your profile README in action!

### Optional: Add GitHub Stats

The profile README includes several dynamic badges and stats:

1. **GitHub Stats**: Automatically generated, no setup needed
2. **Activity Graph**: Works automatically
3. **Profile Views Counter**: Updates automatically

These use external services:
- https://github-readme-stats.vercel.app
- https://github-readme-streak-stats.herokuapp.com
- https://github-readme-activity-graph.vercel.app

## 3. Portfolio Site (GitHub Pages)

### Setup

**Step 1: Create the repository**

```bash
# Using GitHub CLI
gh repo create JoshuaAFerguson.github.io --public --clone

# Or via web: https://github.com/new
# Repository name: JoshuaAFerguson.github.io
# Visibility: Public
```

**Step 2: Add the portfolio site**

```bash
# Navigate to the repository
cd JoshuaAFerguson.github.io

# Copy the portfolio HTML
cp ~/dotfiles/templates/portfolio/index.html index.html

# Customize it
vim index.html
```

**Step 3: Customize**

Edit `index.html` and update:
- [ ] Meta tags (description, keywords)
- [ ] Social media links
- [ ] LinkedIn URL
- [ ] Twitter handle (if applicable)
- [ ] About section content
- [ ] Skills and expertise
- [ ] Project cards (titles, descriptions, links)
- [ ] Contact information

**Step 4: Push changes**

```bash
git add index.html
git commit -m "Initial portfolio site"
git push
```

**Step 5: Enable GitHub Pages**

1. Go to repository settings: https://github.com/JoshuaAFerguson/JoshuaAFerguson.github.io/settings/pages
2. Under "Source", select `main` branch
3. Click "Save"

**Step 6: Verify**

Wait 1-2 minutes, then visit: https://joshuaaferguson.github.io

### Adding Custom Domain (Optional)

If you have a custom domain:

**Step 1: Add CNAME file**

```bash
cd JoshuaAFerguson.github.io
echo "yourdomain.com" > CNAME
git add CNAME
git commit -m "Add custom domain"
git push
```

**Step 2: Configure DNS**

Add DNS records at your domain registrar:

```
Type: CNAME
Name: www
Value: joshuaaferguson.github.io
```

For apex domain (yourdomain.com), add:

```
Type: A
Name: @
Value: 185.199.108.153
Value: 185.199.109.153
Value: 185.199.110.153
Value: 185.199.111.153
```

**Step 3: Update GitHub Pages settings**

1. Go to repository settings → Pages
2. Enter your custom domain
3. Check "Enforce HTTPS"

### Enhancing the Portfolio

**Add a blog section:**

```bash
# Create a blog directory
mkdir blog
cd blog

# Create first blog post
cat > first-post.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My First Blog Post | Joshua Ferguson</title>
    <!-- Copy styles from index.html -->
</head>
<body>
    <article>
        <h1>My First Blog Post</h1>
        <p>Content here...</p>
        <a href="../index.html">Back to Home</a>
    </article>
</body>
</html>
EOF
```

**Add projects as separate pages:**

```bash
# Create projects directory
mkdir projects

# Create detailed project pages
cd projects
cat > ai-infra-k3s.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AI Infrastructure K3s | Joshua Ferguson</title>
</head>
<body>
    <!-- Detailed project information -->
</body>
</html>
EOF
```

**Add a resume page:**

```bash
cat > resume.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Resume | Joshua Ferguson</title>
</head>
<body>
    <!-- Your resume content -->
</body>
</html>
EOF
```

## Testing Locally

Before pushing, test your portfolio locally:

```bash
# Using Python
cd JoshuaAFerguson.github.io
python3 -m http.server 8000

# Open browser to: http://localhost:8000
```

## Updating Content

### Regular Updates

**Profile README:**
```bash
cd ~/JoshuaAFerguson
vim README.md
git add README.md
git commit -m "Update profile README"
git push
```

**Portfolio Site:**
```bash
cd ~/JoshuaAFerguson.github.io
vim index.html
git add index.html
git commit -m "Update portfolio content"
git push
```

Changes appear on GitHub Pages within 1-2 minutes.

## Analytics (Optional)

Add Google Analytics to track portfolio visits:

1. Sign up at https://analytics.google.com
2. Get your tracking ID (G-XXXXXXXXXX)
3. Add to `<head>` of index.html:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

## SEO Optimization

**Add sitemap.xml:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://joshuaaferguson.github.io/</loc>
    <lastmod>2025-01-06</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
```

**Add robots.txt:**

```
User-agent: *
Allow: /
Sitemap: https://joshuaaferguson.github.io/sitemap.xml
```

## Troubleshooting

### GitHub Pages not working

1. Check repository settings → Pages
2. Ensure branch is set to `main`
3. Wait 1-2 minutes for deployment
4. Check GitHub Actions tab for build status

### 404 Error on GitHub Pages

- Ensure `index.html` is in the root directory
- Check file name is exactly `index.html` (lowercase)
- Clear browser cache

### Profile README not showing

- Repository name must match username exactly: `JoshuaAFerguson`
- Repository must be public
- README.md must be in root directory
- May take a few minutes to appear

## Next Steps

After setup:

1. ✅ Share your portfolio on LinkedIn
2. ✅ Add portfolio link to email signature
3. ✅ Include on resume
4. ✅ Share with professional network
5. ✅ Update regularly with new projects
6. ✅ Write blog posts about your work
7. ✅ Engage with GitHub community

## Resources

- GitHub Pages Documentation: https://docs.github.com/en/pages
- GitHub Profile README Guide: https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/customizing-your-profile/managing-your-profile-readme
- Markdown Guide: https://www.markdownguide.org/
- HTML/CSS Reference: https://developer.mozilla.org/
