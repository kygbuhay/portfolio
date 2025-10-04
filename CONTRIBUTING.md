# Contributing to the Portfolio

Thank you for your interest in this portfolio project! While this is primarily a personal portfolio, contributions, suggestions, and feedback are welcome.

## How to Contribute

### Reporting Issues or Suggestions

If you notice any issues or have suggestions for improvements:

1. Check existing [Issues](../../issues) to avoid duplicates
2. Open a new issue with:
   - Clear description of the problem or suggestion
   - Steps to reproduce (for bugs)
   - Expected vs. actual behavior
   - Screenshots if applicable

### Code Contributions

#### Setup Development Environment

```bash
# Fork and clone the repository
git clone https://github.com/yourusername/portfolio.git
cd portfolio

# Set up environment
python -m venv .venv
source .venv/bin/activate
pip install -e .
```

#### Making Changes

1. **Create a branch:**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/issue-description
   ```

2. **Make your changes:**
   - Follow existing code style and conventions
   - Update documentation if needed
   - Test your changes thoroughly

3. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Brief description of changes"
   ```

4. **Push and create Pull Request:**
   ```bash
   git push origin feature/your-feature-name
   ```

## Code Style Guidelines

### Python Code

- Follow [PEP 8](https://pep8.org/) style guide
- Use type hints where appropriate
- Add docstrings to functions and classes
- Keep functions focused and single-purpose

Example:
```python
def clean_column_names(df: pd.DataFrame) -> pd.DataFrame:
    """
    Standardize column names to lowercase with underscores.

    Args:
        df: Input DataFrame with any column naming convention

    Returns:
        DataFrame with cleaned column names
    """
    df.columns = df.columns.str.lower().str.replace(' ', '_')
    return df
```

### Jupyter Notebooks

- Use clear markdown headers to structure analysis
- Include narrative explanations before code cells
- Keep outputs clean (clear unnecessary debug prints)
- Number notebooks sequentially (01_, 02_, etc.)

### Shell Scripts

- Include descriptive comments
- Use shellcheck-compliant syntax
- Handle errors gracefully
- Provide user-friendly messages

## Testing

Before submitting changes:

1. **Test imports:**
   ```bash
   python -c "from src import setup_notebook; print('OK')"
   ```

2. **Test scripts:**
   ```bash
   make export-notebooks  # Should complete without errors
   make export-figures    # Should handle empty notebooks
   ```

3. **Clean up:**
   ```bash
   make clean
   ```

## Portfolio Structure Conventions

When adding new case studies, follow this structure:

```
case_study_name/
├── notebooks/          # Numbered: 01_*, 02_*, etc.
├── data/
│   ├── raw/           # Original, immutable data
│   └── processed/     # Cleaned data
├── docs/
│   ├── notes/         # Technical analysis notes
│   ├── modeling/      # Model results and comparisons
│   └── stakeholders/  # Business-facing documents
└── reports/
    ├── figures/       # Exported visualizations
    └── notebooks_md/  # Markdown exports
```

## Accessibility Standards

All visualizations must:
- Use colorblind-friendly palettes
- Include multiple visual cues (not just color)
- Meet WCAG AA contrast standards
- Have descriptive titles and labels

Use the built-in helpers:
```python
from src.viz_access import quick_accessibility_setup
quick_accessibility_setup()
```

## Documentation

- Update README.md if adding new features
- Update SETUP.md for installation/usage changes
- Add inline comments for complex logic
- Include docstrings for all public functions

## Questions?

Feel free to open an issue for any questions about contributing!

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (if applicable).
