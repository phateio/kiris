# Contributing Guidelines

> **⚠️ Source of Truth**: [CONTRIBUTING.md](https://denpaio.github.io/CONTRIBUTING.md)  
> 
> **MANDATORY: Version Check Before Any Work**:
> - **ALWAYS verify this file matches the source before making any changes**
> - If outdated, MUST update to latest version first via PR
> - To check: `curl -s https://denpaio.github.io/CONTRIBUTING.md | diff CONTRIBUTING.md -`
> - To sync: `curl -o CONTRIBUTING.md https://denpaio.github.io/CONTRIBUTING.md`
> - DO NOT modify this file directly - all changes must be made in the source
> - After source updates, submit a PR to update this repository's copy

## Code Standards

### Language & Documentation
- **Code comments**: English preferred, but follow existing context
- **Documentation**: English preferred
- **Principle**: Self-documenting code over redundant comments

### Style Enforcement
- **Ruby**: Follow Rubocop conventions (`.rubocop.yml`)
- **JavaScript**: Follow ESLint conventions (`.eslintrc`)
- **Python**: Follow PEP 8 conventions
- **Go**: Follow gofmt conventions
- **Java**: Follow [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)

### Commit Messages
- Follow [Conventional Commits](https://www.conventionalcommits.org/) specification

## Workflow

1. Run linters before committing:
```bash
# Ruby
rubocop -A

# JavaScript
eslint --fix .

# Python
black . && isort .

# Go
gofmt -w .

# Java
# Use google-java-format plugin in your IDE or:
# java -jar google-java-format.jar --replace src/**/*.java

# Terraform
terraform fmt -recursive
terraform validate
tflint

# Helm
helm lint helm/*/

# YAML
yamllint .
```

2. Ensure all tests pass
3. Write clear, self-documenting code
4. Commit with conventional format: `type(scope): description`

---

<!-- For Claude Code: CRITICAL - Before any work, verify CONTRIBUTING.md is up-to-date with source. If outdated, stop and request update via PR first. Strictly follow all standards above. Verify linter compliance before marking tasks complete. -->