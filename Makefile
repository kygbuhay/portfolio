.PHONY: help install export-notebooks export-figures new-notebook clean

help:
	@echo "Portfolio Management Commands"
	@echo "=============================="
	@echo ""
	@echo "Setup:"
	@echo "  make install              Install portfolio utilities (pip install -e .)"
	@echo ""
	@echo "Notebook Operations:"
	@echo "  make new-notebook         Create a new Jupyter notebook interactively"
	@echo "  make export-notebooks     Export notebooks to markdown"
	@echo "  make export-figures       Export figures from notebooks"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean                Remove Python cache files and build artifacts"

install:
	@echo "📦 Installing portfolio utilities..."
	pip install -e .
	@echo "✅ Installation complete!"

export-notebooks:
	@echo "📝 Exporting notebooks to markdown..."
	./scripts/export_notebooks_menu.sh

export-figures:
	@echo "📊 Exporting figures from notebooks..."
	./scripts/export_figures_menu.sh

new-notebook:
	@echo "📓 Creating new notebook..."
	./scripts/new_notebook.sh

clean:
	@echo "🧹 Cleaning up Python cache and build files..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ipynb_checkpoints" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name "*.pyo" -delete 2>/dev/null || true
	rm -rf build/ dist/ 2>/dev/null || true
	@echo "✅ Cleanup complete!"
