# Steps to Update Blog

1. Backup old blog files.
1. Clone the latest version: `git clone git@github.com:mmistakes/minimal-mistakes.git`
1. Open `_setup.ps1` from old blog and update `$oldBlogPath` and `$newBlogPath`.
1. Copy `_setup.ps1` from old blog into new repo root.
1. Run `_setup.ps1` in the new repo root to action the following steps:
   1. Cleanup unwanted files as per suggestions in README.
   1. Copy old blog files into the new repo root.
1. Manually copy old `_config.yml` settings to the new `_config.yml`; checking for new settings.
1. Open `archive-single.html` and modify `truncate: <value>` to something like `truncate: 300`.
