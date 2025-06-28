{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  alsa-lib,
  ffmpeg,
  kdePackages,
  kdsingleapplication,
  pipewire,
  taglib,
  libebur128,
  libvgm,
  libsndfile,
  libarchive,
  libopenmpt,
  game-music-emu,
  SDL2,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fooyin";
  version = "0.8.1b";

  src = fetchFromGitHub {
    owner = "ludouzi";
    repo = "fooyin";
    rev = "4218a013c3ae669d47d8e98c0fdf8f21fa6bb811";#"v" + finalAttrs.version;
    hash = "sha256-6zH6aeyhswGbymPuzZXOgi+SD9oHy5vIxgBAAg376Vs=";
  };

  buildInputs = [
    kdePackages.qcoro
    kdePackages.qtbase
    kdePackages.qtsvg
    kdePackages.qtwayland
    taglib
    ffmpeg
    kdsingleapplication
    # output plugins
    alsa-lib
    pipewire
    SDL2
    # input plugins
    libebur128
    libvgm
    libsndfile
    libarchive
    libopenmpt
    game-music-emu
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.qttools
    kdePackages.wrapQtAppsHook
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.finalPackage.doCheck)
    # we need INSTALL_FHS to be true as the various artifacts are otherwise just dumped in the root
    # of $out and the fixupPhase cleans things up anyway
    (lib.cmakeBool "INSTALL_FHS" true)
  ];

  # Remove after next release
  #patches = [
  #  (fetchpatch {
  #    name = "qbrush.patch";
  #    url = "https://github.com/fooyin/fooyin/commit/e44e08abb33f01fe85cc896170c55dbf732ffcc9.patch";
  #    hash = "sha256-soDj/SFctxxsnkePv4dZgyDHYD2eshlEziILOZC4ddM=";
  #  })
  #];

  env.LANG = "C.UTF-8";

  meta = {
    description = "Customisable music player";
    homepage = "https://www.fooyin.org/";
    downloadPage = "https://github.com/fooyin/fooyin";
    mainProgram = "fooyin";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.linux;
  };
})
