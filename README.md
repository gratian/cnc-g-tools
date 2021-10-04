# cnc-g-tools
Tools for parsing CNC G-code (NIST-RS274NGC)

# Build

1. When building from a newly cloned repo:

  autoreconf

2. If autoreconf complains:

  automake --add-missing

3. Generate G/M code support (manual step for now)

  cd src/code-gen
  ./clean.sh
  ./build.sh
  ./run.sh
  cd ../..

4. Configure and build

  mkdir build
  cd build
  ../configure
  make
