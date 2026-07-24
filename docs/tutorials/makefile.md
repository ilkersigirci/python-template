# Useful Makefile commands

```bash
# All available commands
make
make help

# Run all tests
make -s test

# Run specific tests
make -s test-one TEST_MARKER=<TEST_MARKER>

# Remove unnecessary files such as build,test, cache
make -s clean

# Install prek and git hooks (once)
make -s install-prek

# Run all hooks (lint + format + checks)
make -s prek

# Profile a file
make -s profile PROFILE_FILE_PATH=<PATH_TO_FILE>
```
