{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  cython,
  numpy,
  setuptools,
  wheel,
  ta-lib,
  gcc,
}:

buildPythonPackage rec {
  pname = "ta-lib";
  version = "0.6.8";
  pyproject = true;

  src = fetchPypi {
    pname = "ta_lib";
    version = "0.6.8";
    hash = "sha256-OpGVKZ3519Km6dFr69a3BrDqmeS4cYZMSwNMJXfiGnc=";
  };

  build-system = [ 
    numpy 
    cython 
    setuptools 
    wheel 
  ];

  propagatedBuildInputs = [
    ta-lib
  ];

  nativeBuildInputs = [
    gcc
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  # has no tests
  doCheck = false;

  dontCheckRuntimeDeps = true;

  meta = {
    homepage = "https://github.com/ta-lib/ta-lib-python";
    changelog = "https://github.com/ta-lib/ta-lib-python/releases/tag/v${version}";
    description = "This is a Python wrapper for TA-LIB based on Cython instead of SWIG.";
    license = lib.licenses.bsd2;
  };
}