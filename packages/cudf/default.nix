/*
  RAPIDS cuDF 26.2.1 — pre-built wheel bundle for Python 3.13 + CUDA 12.

  All RAPIDS packages (libcudf, pylibcudf, cudf, rmm, …) and their direct
  non-nixpkgs dependencies are unpacked from PyPI manylinux wheels into a
  single derivation so that relative $ORIGIN RPATHs between the bundled .so
  files keep working.  autoPatchelfHook fixes any remaining system-library
  references (libstdc++, libcudart, etc.).

  Caller must supply cudaPackages matching the system CUDA version:
    rapids-cudf = callPackage ./nix/rapids-cudf.nix {
      cudaPackages = pkgs.cudaPackages_12_8;
    };
*/
{ lib
, buildPythonPackage
, fetchurl
, autoPatchelfHook
, unzip
, stdenv
, cudaPackages
, zlib
, python    # the Python interpreter — injected automatically by buildPythonPackage
}:

let
  # ── wheel fetches (RAPIDS 26.2 + deps, Python 3.13, x86_64-linux) ────────
  whl = url: hash: fetchurl { inherit url hash; };

  wheels = [
    # Native-lib wheels (contain bundled .so files)
    (whl
      "https://files.pythonhosted.org/packages/3c/e3/17a78856b27f4d3f510dbcb8897cd2595cc9bec9b88b59181a7d427a973d/libkvikio_cu12-26.2.0-py3-none-manylinux_2_28_x86_64.whl"
      "sha256-O683Lb1rS5HifRY05IYQjeQ9LJRl+K3Pwtbu9uGU0Vc=")
    (whl
      "https://files.pythonhosted.org/packages/08/ab/844fcbaa46cc1242632b4b94b4ffc210ec3d8d8f30ad8f7f1c27767389a9/nvidia_libnvcomp_cu12-5.1.0.21-py3-none-manylinux_2_28_x86_64.whl"
      "sha256-aN5hGD7bmocMmmCCc6K12pfeoY41UglsYfr9m7JonbA=")
    (whl
      "https://files.pythonhosted.org/packages/86/88/861542357455e5f96e69f4f6a70f88a6372db56b43d7d4b3db0c6c01e092/librmm_cu12-26.2.0-py3-none-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-1O0ao1VOkFYq188nbGHVb6mb5Ian/BWL7qMydQ0goOc=")
    (whl
      "https://files.pythonhosted.org/packages/4b/fe/11fa828e1481dfe100dbb8f733475a1d2f834dea7d2e4373786963f79446/libcudf_cu12-26.2.1-py3-none-manylinux_2_28_x86_64.whl"
      "sha256-TNZCIRqfFaXNYa/QE6+64//wp4tbTDDJBbThLcDbpKE=")

    # Pure-Python / tiny runtime wheels
    (whl
      "https://files.pythonhosted.org/packages/69/b6/139d9df6d0f7bd289a9a6286cecfff999e41c36865515d7fdb56b7b32a14/rapids_logger-0.2.3-py3-none-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-f+Z+9AScXYumFUdGMl3PfMDzJ/DvqPJhH8j2TmdRD2A=")
    (whl
      "https://files.pythonhosted.org/packages/52/07/7978a4c4d8e70620170aa247ce16241a72d4cf6e4336bd3b296926baf7df/cuda_pathfinder-1.1.0-py3-none-any.whl"
      "sha256-Pmb+Cvjq0g7KJeB30uDLLcwCfUKX1VCnT5mgIR5hB5k=")
    (whl
      "https://files.pythonhosted.org/packages/57/69/4a79126959ad6f1653504122ee1eb22d089dd6272d3fa37694dcdeb78ba5/cuda_python-12.9.6-py3-none-any.whl"
      "sha256-7VzzDhEpcp7s9GBd/26LzoTy0wwXsXx+WsS3ZEjeNdI=")
    (whl
      "https://files.pythonhosted.org/packages/72/76/20fa66124dbe6be5cafeb312ece67de6b61dd91a0247d1ea13db4ebb33c2/cachetools-5.5.2-py3-none-any.whl"
      "sha256-0moivMYuuVw76r2fHuXoINPScE/ilny+NQ4gyP/NPwo=")

    # Python extension wheels (contain .so CUDA extensions)
    (whl
      "https://files.pythonhosted.org/packages/18/23/6db3aba46864aee357ab2415135b3fe3da7e9f1fa0221fa2a86a5968099c/cuda_bindings-13.2.0-cp313-cp313-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-fcoNoFPTtMxIae/0nGHAPzxduqC81xIxejWNW48/OF0=")
    (whl
      "https://files.pythonhosted.org/packages/24/66/52f200a80f33c4a6a3c5da282fb2167192e20c8bc1fa4dbf33602d63be8f/cuda_core-0.5.1-cp313-cp313-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-+/vddT1YYJxriCvOXLtuNBozihUGA7OEkDmpZkFHSx0=")
    (whl
      "https://files.pythonhosted.org/packages/b1/c0/4a5bb7897918de7c7e0191d9342df8ae4cb797ff07276e0f20d13e497ce7/nvtx-0.2.15-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-EHSWhmM/iArVPc27IXn61BtF3PW3Yx1KEHCld1d704Y=")
    (whl
      "https://files.pythonhosted.org/packages/c4/43/ca69eda73a599bee6f83cbf34b26b47ef4e4d236c034ba83f36cef1dffa2/rmm_cu12-26.2.0-cp313-cp313-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-i3JqLU4oddBv6Nd2SHvM7Uzo/H2fLDzUSmyR6cdE+Sw=")
    (whl
      "https://files.pythonhosted.org/packages/22/44/9820e2f00ceb164824baf5c6553b2f5b50a6dfa96576ea2b17d7c773dda4/numba_cuda-0.22.2-cp313-cp313-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-3BkB0y7ziLbBAEZ84ruXF2m8KqAx7TAEpmTMeh75v04=")
    (whl
      "https://files.pythonhosted.org/packages/8b/93/5007a6f631001ce1407ce2b219ed461162724c8675b2c127db0560bb6d09/pylibcudf_cu12-26.2.1-cp313-cp313-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-zK4MZPvQ8FBQ3SFOBe7YPa2+ZETflIW//uAN6OBOpvk=")

    # Top-level cudf Python package (pure-Python, depends on pylibcudf)
    (whl
      "https://files.pythonhosted.org/packages/b4/cd/09e77423dee5a6924ca3e149949aa510ef6ac9e6914996eab1dd086d6279/cudf_cu12-26.2.1-cp313-cp313-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-HaytiXcdTa0PJJSWWaHWiJAvLLsk14xhq0bdpNxuNbE=")
  ];

in
buildPythonPackage {
  pname   = "rapids-cudf";
  version = "26.2.1";

  # "other" gives us full control of all phases; we own unpack + install.
  format = "other";

  # src is required by buildPythonPackage but dontUnpack = true means it
  # will never be extracted — we iterate over `wheels` ourselves.
  src        = builtins.head wheels;
  dontUnpack = true;
  dontBuild  = true;

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  # autoPatchelfHook will search these for shared libraries to resolve SONAME
  # references left after the $ORIGIN relative RPATHs are expanded.
  buildInputs = [
    stdenv.cc.cc.lib                # libstdc++.so.6
    cudaPackages.cuda_cudart        # libcudart.so.12
    cudaPackages.libnvjitlink       # libnvJitLink.so.12 (runtime-loaded by libcudf)
    zlib                            # libz.so.1
  ];

  # libcuda.so.1 is the Nvidia driver itself — never present at build time,
  # always available at runtime via /run/opengl-driver on NixOS.
  # The remaining entries are CUDA toolkit libs that RAPIDS bundles inside
  # its own .libs directories; autoPatchelf doesn't need to resolve them.
  autoPatchelfIgnoreMissingDeps = [
    "libcuda.so.1"
    "libnvJitLink.so.12"
    "libnvrtc.so.12"
    "libcufft.so.11"
    "libcusolver.so.11"
    "libcusparse.so.12"
    "libcublas.so.12"
    "libcublasLt.so.12"
    "libcurand.so.10"
    "libcupti.so.12"
  ];

  installPhase = ''
    runHook preInstall

    siteDir="$out/${python.sitePackages}"
    mkdir -p "$siteDir"

    # Unzip every wheel directly into site-packages.
    # Because all wheels land in the same directory, relative $ORIGIN RPATHs
    # (e.g. $ORIGIN/../libcudf_cu12.libs) resolve correctly at runtime.
    for whl in ${lib.concatStringsSep " " (map toString wheels)}; do
      echo "  unpacking $(basename $whl)..."
      unzip -qo "$whl" -d "$siteDir"
    done

    # Remove wheel-internal RECORD/INSTALLER noise that confuses some tooling
    find "$siteDir" -name "RECORD" -delete

    runHook postInstall
  '';

  # Runtime dependencies that ARE in nixpkgs (already in the Python env)
  propagatedBuildInputs = with python.pkgs; [
    cupy
    numpy
    pandas
    pyarrow
    numba
    packaging
    typing-extensions
    rich
    fsspec
  ];

  dontCheckRuntimeDeps = true;
  doCheck = false;

  meta = {
    description = "RAPIDS cuDF — GPU-accelerated DataFrame library (NVIDIA RAPIDS 26.2)";
    homepage    = "https://rapids.ai";
    license     = lib.licenses.asl20;
    platforms   = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
