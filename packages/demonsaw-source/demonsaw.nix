{ lib
, stdenv
, pkgs
, fetchFromGitHub
, boost
, qt5
, autoPatchelfHook
, makeWrapper
, dbus
, fontconfig
, freetype
, glib
, libGL
, libxkbcommon
, xorg
, zlib
, removeReferencesTo
, extraConfig ? ""
, tomlName ? ".demonsaw.toml"
, tomlLocation ? "$HOME/.config/"
, buildAnonProfile ? true
}:

stdenv.mkDerivation rec {
  pname = "demonsaw";
  version = "4.0-b036d45";

  src = fetchFromGitHub {
    owner = "demonsaw";
    repo = "Code";
    rev = "b036d455e9e034d7fd178e63d5e992242d62989a";
    hash = "sha256-XZSVEk7y3mq8CdQJvO3EJmieUafpDvqw9TnWM1Bygz8=";
  };

  # The ds4 subdirectory is the C++ Qt version
  sourceRoot = "source/ds4";

  nativeBuildInputs = [
    qt5.qmake
    autoPatchelfHook
    makeWrapper
    removeReferencesTo
    pkgs.python3
  ];

  buildInputs = [
    boost
    qt5.qtbase
    qt5.qtsvg
    dbus
    fontconfig
    freetype
    glib
    libGL
    libxkbcommon
    xorg.libX11
    zlib
  ];

  # qmake hook would run from wrong directory; we do it ourselves in configurePhase.
  # Wrapping is done manually below so we get toml/anon profile control per-binary.
  dontUseQmakeConfigure = true;
  dontWrapQtApps = true;

  patches = [
    ./0001-fix-http-socket-open-race.patch
    ./0002-fix-security-str-codegen.patch
    ./0003-fix-chat-widget-spam-timer-null.patch
    ./0004-fix-boost187-compat.patch
  ];

  postPatch = ''
    # Fix hardcoded ROOT path so build artifacts land inside the writable source tree.
    # $$PWD inside 4_deb.pri resolves to the code/ directory at qmake parse time,
    # so ROOT = $$PWD/.. = the ds4/ directory that contains code/ and build/.
    substituteInPlace code/4_deb.pri \
      --replace 'ROOT = /demonsaw_4' 'ROOT = $$PWD/..'

    # Point boost headers to the Nix boost dev output.
    substituteInPlace code/4_deb.pri \
      --replace 'BOOST_INC = $$BOOST' "BOOST_INC = ${boost.dev}/include"

    # Point boost lib dir to the Nix boost output
    substituteInPlace code/4_deb.pri \
      --replace 'BOOST_LIB = $$LIB/0_boost/$$PLATFORM' "BOOST_LIB = ${boost}/lib"

    # Replace the versioned static .a lib name patterns with simple dynamic -l flags.
    # nixpkgs boost only ships .so files (no versioned .a files).
    sed -i 's|BOOST_ATOMIC_LIB = .*|BOOST_ATOMIC_LIB = -lboost_atomic|'         code/4_deb.pri
    sed -i 's|BOOST_CHRONO_LIB = .*|BOOST_CHRONO_LIB = -lboost_chrono|'         code/4_deb.pri
    sed -i 's|BOOST_DATE_TIME_LIB = .*|BOOST_DATE_TIME_LIB = -lboost_date_time|' code/4_deb.pri
    sed -i 's|BOOST_FILESYSTEM_LIB = .*|BOOST_FILESYSTEM_LIB = -lboost_filesystem|' code/4_deb.pri
    sed -i 's|BOOST_LOCALE_LIB = .*|BOOST_LOCALE_LIB = -lboost_locale|'         code/4_deb.pri
    sed -i 's|BOOST_REGEX_LIB = .*|BOOST_REGEX_LIB = -lboost_regex|'            code/4_deb.pri
    sed -i 's|BOOST_SYSTEM_LIB = .*|BOOST_SYSTEM_LIB = -lboost_system|'         code/4_deb.pri
    sed -i 's|BOOST_THREAD_LIB = .*|BOOST_THREAD_LIB = -lboost_thread|'         code/4_deb.pri

    # Prepend the -L search path so the linker can find the boost .so files
    sed -i 's|BOOST_LIBS = \(.*\)|BOOST_LIBS = -L$$BOOST_LIB \1|' code/4_deb.pri

    # GCC 14 tightened transitive-include rules; prime.cpp uses std::runtime_error
    # but never directly includes <stdexcept>.
    sed -i 's|#include <cassert>|#include <cassert>\n#include <stdexcept>|' \
      code/4_core/security/algorithm/prime.cpp

    # Linux filesystems are case-sensitive; client_window.cpp has a wrong-case include.
    sed -i 's|"Widget/option/option_widget.h"|"widget/option/option_widget.h"|' \
      code/4_client_desktop/window/client_window.cpp

    # GCC 12 rejects UTF-16 surrogate pairs in \uXXXX string literals.
    # \uD83D\uDD25 is the UTF-16 surrogate pair for U+1F525 (🔥 Fire emoji).
    # Replace with the proper C++ universal character name \U0001F525.
    sed -i 's|\\uD83D\\uDD25|\\U0001F525|g' \
      code/4_core_gui/dialog/about_dialog.cpp

    # Enable debug symbols for crash analysis (uncomment the -g lines in 4_deb.pri)
    # and disable the linker -Wl,-s strip flag so the symbols survive into the binary.
    sed -i 's|#QMAKE_CFLAGS_RELEASE \*= -g|QMAKE_CFLAGS_RELEASE *= -g|' code/4_deb.pri
    sed -i 's|#QMAKE_CXXFLAGS_RELEASE \*= -g|QMAKE_CXXFLAGS_RELEASE *= -g|' code/4_deb.pri
    sed -i 's|QMAKE_LFLAGS_RELEASE = -Wl,-s|QMAKE_LFLAGS_RELEASE =|' code/4_deb.pri

    # Force C++14 standard for the 64-bit path. Without this, GCC defaults to
    # C++17 which introduces std::make_optional, causing ambiguity with
    # boost::make_optional in the bundled cppnetlib (uri_parts.hpp, unqualified call).
    sed -i '/PLATFORM_TAG = x64/a\\tQMAKE_CXXFLAGS *= -std=c++14\n\tQMAKE_CFLAGS *= -std=c++14' code/4_deb.pri

    # boost 1.74+ removed boost/asio/io_service.hpp; use the umbrella boost/asio.hpp instead.
    find code/0_cppnetlib -name '*.hpp' -o -name '*.ipp' -o -name '*.cpp' | \
      xargs sed -i 's|#include <boost/asio/io_service.hpp>|#include <boost/asio.hpp>|g'

    # boost 1.87 removed boost::asio::io_service as a name (was typedef for io_context since 1.66).
    # Applied to all code/ subdirectories (not just cppnetlib).
    find code/ -name '*.hpp' -o -name '*.ipp' -o -name '*.cpp' -o -name '*.h' | \
      xargs sed -i 's|boost::asio::io_service|boost::asio::io_context|g'

    # boost 1.87 removed boost::asio::mutable_buffers_1; mutable_buffer is a direct replacement.
    find code/0_cppnetlib -name '*.hpp' -o -name '*.ipp' -o -name '*.cpp' | \
      xargs sed -i 's|boost::asio::mutable_buffers_1|boost::asio::mutable_buffer|g'

    # boost 1.74+ removed get_io_service() from async I/O objects (resolver, socket, etc.).
    # The replacement is get_executor().context() cast to io_context&.
    find code/0_cppnetlib -name '*.hpp' -o -name '*.ipp' -o -name '*.cpp' | \
      xargs sed -i 's|resolver\.get_io_service()|static_cast<boost::asio::io_context\&>(resolver.get_executor().context())|g'

    # boost 1.76+ renamed expires_from_now() to expires_after() on steady_timer.
    find code/ -name '*.hpp' -o -name '*.ipp' -o -name '*.cpp' -o -name '*.h' | \
      xargs sed -i 's|expires_from_now|expires_after|g'

    # boost 1.83 no longer pulls u32_to_u8_iterator / u8_to_u32_iterator into scope
    # transitively from spirit/qi.hpp. Add the explicit include to parsers.ipp.
    sed -i 's|#include <boost/spirit/include/qi.hpp>|#include <boost/spirit/include/qi.hpp>\n#include <boost/regex/pending/unicode_iterator.hpp>|' \
      code/0_cppnetlib/boost/network/protocol/http/server/impl/parsers.ipp

    # boost/detail/endian.hpp was removed in newer boost. Any file that includes it also
    # includes boost/endian/conversion.hpp which provides a superset; just drop the stale include.
    find code/4_core -name '*.cpp' -o -name '*.h' | \
      xargs sed -i '/#include <boost\/detail\/endian.hpp>/d'

    # boost 1.87 removed resolver::query and resolver::iterator from tcp::resolver.
    # http_service.h uses async_resolve with the old query-object API; update to the new
    # string-based overload whose callback receives results_type instead of an iterator.
    sed -i '/boost::asio::ip::tcp::resolver::query query/d' \
      code/4_core/http/http_service.h
    sed -i 's|resolver->async_resolve(query, \[|resolver->async_resolve(address, std::to_string(port), [|' \
      code/4_core/http/http_service.h
    sed -i 's|boost::asio::ip::tcp::resolver::iterator it)|boost::asio::ip::tcp::resolver::results_type results)|' \
      code/4_core/http/http_service.h
    sed -i 's|if (!error \&\& (it != boost::asio::ip::tcp::resolver::iterator()))|if (!error \&\& !results.empty())|' \
      code/4_core/http/http_service.h
    sed -i 's|endpoint = it->endpoint();|endpoint = results.begin()->endpoint();|' \
      code/4_core/http/http_service.h

    # http_service.cpp: sync resolve() also uses the old query-object API.
    sed -i '/boost::asio::ip::tcp::resolver::query query/d' \
      code/4_core/http/http_service.cpp
    sed -i 's|const auto it = resolver\.resolve(query);|const auto it = resolver.resolve(address, std::to_string(port));|' \
      code/4_core/http/http_service.cpp
    sed -i 's|if (it != boost::asio::ip::tcp::resolver::iterator())|if (!it.empty())|' \
      code/4_core/http/http_service.cpp
    sed -i 's|return it->endpoint();|return it.begin()->endpoint();|' \
      code/4_core/http/http_service.cpp

    # http_socket.cpp: timer->cancel(error_code) removed; use zero-arg cancel().
    sed -i 's|timer->cancel(error)|timer->cancel()|g' \
      code/4_core/http/http_socket.cpp

    # strand_component.h: m_strand->dispatch/post(handler) single-arg removed in boost 1.87.
    # Use boost::asio::dispatch/post free functions.
    sed -i 's|m_strand->dispatch(\[t\]()|boost::asio::dispatch(*m_strand, [t]()|g' \
      code/4_core/component/service/strand_component.h
    sed -i 's|m_strand->post(\[t\]()|boost::asio::post(*m_strand, [t]()|g' \
      code/4_core/component/service/strand_component.h

    # http_acceptor.cpp: socket_base::max_connections removed in boost 1.87;
    # max_listen_connections is the replacement (added in 1.66).
    sed -i 's|boost::asio::socket_base::max_connections|boost::asio::socket_base::max_listen_connections|g' \
      code/4_core/http/http_acceptor.cpp

    # http_socket.cpp: boost::asio::buffer_cast removed in boost 1.78.
    # streambuf.data() returns const_buffer; call .data() on it again to get const void*.
    sed -i 's|boost::asio::buffer_cast<const char\*>(\(.*\)\.data())|static_cast<const char*>(\1.data().data())|g' \
      code/4_core/http/http_socket.cpp

  '';

  configurePhase = ''
    runHook preConfigure
    cd code
    qmake 4_config.pro CONFIG+=release
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    make -j''${NIX_BUILD_CORES:-1}
    runHook postBuild
  '';

  desktopItem = pkgs.makeDesktopItem rec {
    name = "demonsaw";
    desktopName = "Demonsaw";
    genericName = "Private Messenger";
    icon = "${name}";
    exec = "${name} %U";
    keywords = [ "ds4" "demonsaw" "messenger" "chat" ];
    categories = [ "Network" "InstantMessaging" "Chat" ];
  };

  generator_script = pkgs.writeShellScript "generate_demonsaw_toml.sh" ''
    echo "Checking if \"${tomlLocation}\" exists "
    if [ ! -d "${tomlLocation}" ]; then
      echo "Directory not found. making folder in \"${tomlLocation}\""
      mkdir -p "${tomlLocation}"
    fi
    echo "Checking if \"${tomlName}\" exists"
    if [ ! -f "${tomlLocation}${tomlName}" ]; then
      echo "File not found. making file."
      touch ${tomlLocation}${tomlName}
    fi
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin

    # Binaries land in ROOT/build/bin/linux_64/release/ = ../build/bin/linux_64/release/
    # (relative to the code/ directory we cd'd into during configurePhase)
    for bin in 4_client_desktop 4_router_cli 4_client_cli; do
      if [ -f "../build/bin/linux_64/release/$bin" ]; then
        install -Dm755 "../build/bin/linux_64/release/$bin" "$out/bin/$bin"
      fi
    done

    # Qt platform plugins (xcb) live in a versioned subdirectory.
    # Discover the real path at install time so the version glob resolves correctly.
    qt_plugin_path=$(echo ${qt5.qtbase}/lib/qt-5.*/plugins | head -1)

    lib_path="${lib.makeLibraryPath [
      boost
      dbus
      fontconfig
      freetype
      glib
      libGL
      libxkbcommon
      qt5.qtbase
      qt5.qtsvg
      stdenv.cc.cc.lib
      xorg.libX11
      zlib
    ]}"

    ${lib.optionalString (extraConfig == "") ''
      echo "Building local profile wrapper"
      cp ${generator_script} $out/bin/generate_demonsaw_toml.sh
      chmod +x $out/bin/generate_demonsaw_toml.sh

      makeWrapper $out/bin/4_client_desktop $out/bin/demonsaw \
        --prefix LD_LIBRARY_PATH : "$lib_path" \
        --set    QT_QPA_PLATFORM xcb \
        --prefix QT_PLUGIN_PATH : "$qt_plugin_path" \
        --set    QT_DEBUG_PLUGINS 1 \
        --run    $out/bin/generate_demonsaw_toml.sh \
        --add-flags "${tomlLocation}${tomlName}"

      makeWrapper $out/bin/4_client_cli $out/bin/demonsaw_cli \
        --prefix LD_LIBRARY_PATH : "$lib_path" \
        --prefix QT_PLUGIN_PATH : "$qt_plugin_path" \
        --set    QT_DEBUG_PLUGINS 1 \
        --run    $out/bin/generate_demonsaw_toml.sh \
        --add-flags "${tomlLocation}${tomlName}"

      makeWrapper $out/bin/4_router_cli $out/bin/demonsaw_router \
        --prefix LD_LIBRARY_PATH : "$lib_path" \
        --prefix QT_PLUGIN_PATH : "$qt_plugin_path" \
        --set    QT_DEBUG_PLUGINS 1 \
        --run    $out/bin/generate_demonsaw_toml.sh \
        --add-flags "${tomlLocation}${tomlName}"
    ''}

    ${lib.optionalString (extraConfig != "") ''
      echo "Building locked profile wrapper"
      echo '${extraConfig}' > $out/configured_demonsaw.toml

      makeWrapper $out/bin/4_client_desktop $out/bin/demonsaw \
        --prefix LD_LIBRARY_PATH : "$lib_path" \
        --set    QT_QPA_PLATFORM xcb \
        --prefix QT_PLUGIN_PATH : "$qt_plugin_path" \
        --set    QT_DEBUG_PLUGINS 1 \
        --add-flags $out/configured_demonsaw.toml

      makeWrapper $out/bin/4_client_cli $out/bin/demonsaw_cli \
        --prefix LD_LIBRARY_PATH : "$lib_path" \
        --prefix QT_PLUGIN_PATH : "$qt_plugin_path" \
        --set    QT_DEBUG_PLUGINS 1 \
        --add-flags $out/configured_demonsaw.toml

      makeWrapper $out/bin/4_router_cli $out/bin/demonsaw_router \
        --prefix LD_LIBRARY_PATH : "$lib_path" \
        --prefix QT_PLUGIN_PATH : "$qt_plugin_path" \
        --set    QT_DEBUG_PLUGINS 1 \
        --add-flags $out/configured_demonsaw.toml
    ''}

    ${lib.optionalString buildAnonProfile ''
      echo "Building anonymous wrapper"

      makeWrapper $out/bin/4_client_desktop $out/bin/demonsaw-anon \
        --prefix LD_LIBRARY_PATH : "$lib_path" \
        --set    QT_QPA_PLATFORM xcb \
        --prefix QT_PLUGIN_PATH : "$qt_plugin_path" \
        --set    QT_DEBUG_PLUGINS 1

      makeWrapper $out/bin/4_client_cli $out/bin/demonsaw-anon_cli \
        --prefix LD_LIBRARY_PATH : "$lib_path" \
        --prefix QT_PLUGIN_PATH : "$qt_plugin_path" \
        --set    QT_DEBUG_PLUGINS 1
    ''}

    # Desktop item
    mkdir -p "$out/share/applications"
    ln -s "${desktopItem}"/share/applications/* "$out/share/applications/"

    runHook postInstall
  '';

  postInstall = ''
    find "$out" -type f -exec remove-references-to -t ${stdenv.cc} '{}' +
  '';

  meta = with lib; {
    description = "Demonsaw - Secure and anonymous file sharing";
    homepage = "https://www.demonsaw.com/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "demonsaw";
  };
}
